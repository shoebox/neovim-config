local vim = vim

return {
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      local lint = require("lint")

      --- Module root for the buffer so golangci-lint discovers the repo .golangci.* file.
      local function go_project_root(bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name ~= "" then
          local dir = vim.fn.fnamemodify(name, ":p:h")
          local mod = vim.fs.find("go.mod", { upward = true, path = dir })[1]
          if mod then
            return vim.fs.normalize(vim.fn.fnamemodify(mod, ":h"))
          end
          local git = vim.fs.find(".git", { upward = true, path = dir })[1]
          if git then
            return vim.fs.normalize(vim.fn.fnamemodify(git, ":h"))
          end
          return vim.fs.normalize(dir)
        end
        return vim.fs.normalize(vim.fn.getcwd())
      end

      local golangci_tags = "--build-tags=integrationtest,testing,test,debug,e2e"
      local function golangcilint()
        local linter = require("lint.linters.golangcilint")
        if not vim.tbl_contains(linter.args, golangci_tags) then
          table.insert(linter.args, 2, golangci_tags)
        end
        -- Upstream picks paths from Neovim's global cwd at load time; use the open file instead.
        linter.args[#linter.args] = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if bufname == "" then
            return "."
          end
          return vim.fn.fnamemodify(bufname, ":p:h")
        end
        return linter
      end
      lint.linters.golangcilint = golangcilint

      local try_lint = lint._shoebox_try_lint or lint.try_lint
      lint.try_lint = function(names, opts)
        opts = opts or {}
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype
        local go = ft == "go"
        if not go and names then
          local list = type(names) == "table" and names or { names }
          go = vim.tbl_contains(list, "golangcilint")
        end
        if go and not opts.cwd then
          opts.cwd = go_project_root(bufnr)
        end
        return try_lint(names, opts)
      end
      lint._shoebox_try_lint = try_lint

      -- Configure linters by filetype
      lint.linters_by_ft = {
        dockerfile = { "hadolint" },
        go = { "golangcilint" },
        lua = { "luacheck" },
        markdown = { "markdownlint" },
        nix = { "deadnix" },
        yaml = { "yamllint" },
        ["yaml.githubworkflow"] = { "actionlint", "yamllint" },
        ["yaml.ansible"] = { "yamllint" },
      }

      local buffer_timers = {}
      local lint_progress = {}
      local last_lint = {} -- [bufnr] = changedtick at last successful schedule
      local LINT_GROUP = "nvim-lint"
      local lint_group_ready = false

      local function ensure_lint_fidget_group()
        if lint_group_ready then
          return true
        end
        local ok, progress = pcall(require, "fidget.progress")
        if not ok then
          return false
        end
        local config = progress.display.make_config(LINT_GROUP)
        config.name = "nvim-lint"
        require("fidget.notification").set_config(LINT_GROUP, config, true)
        lint_group_ready = true
        return true
      end

      local function lint_fidget_message(linters)
        local names = vim.tbl_keys(linters)
        table.sort(names)
        return table.concat(names, ", ")
      end

      local function lint_fidget_start(bufnr, linter_name)
        if not ensure_lint_fidget_group() then
          return
        end
        local progress = require("fidget.progress")
        local entry = lint_progress[bufnr]
        if not entry then
          lint_progress[bufnr] = {
            handle = progress.handle.create({
              title = "",
              message = linter_name,
              lsp_client = { name = LINT_GROUP },
            }),
            remaining = 1,
            linters = { [linter_name] = true },
          }
          return
        end
        entry.remaining = entry.remaining + 1
        entry.linters[linter_name] = true
        entry.handle:report({ message = lint_fidget_message(entry.linters) })
      end

      local function lint_fidget_done(bufnr)
        local entry = lint_progress[bufnr]
        if not entry then
          return
        end
        entry.remaining = entry.remaining - 1
        if entry.remaining <= 0 then
          entry.handle:finish()
          lint_progress[bufnr] = nil
        end
      end

      if not lint._shoebox_progress then
        local lint_run = lint.lint
        lint.lint = function(linter, opts)
          local proc = lint_run(linter, opts)
          if not proc then
            return nil
          end
          local bufnr = proc.bufnr
          lint_fidget_start(bufnr, linter.name or "lint")
          local publish = proc.publish
          proc.publish = function(self, diagnostics)
            publish(self, diagnostics)
            lint_fidget_done(bufnr)
          end
          local cancel = proc.cancel
          proc.cancel = function(self)
            cancel(self)
            lint_fidget_done(bufnr)
          end
          return proc
        end
        lint._shoebox_progress = true
      end

      -- Skip linting on read-only virtual buffers (Octo review diffs, etc.);
      -- linters expect real files and produce noise on synthetic content.
      local function lintable(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end
        if vim.bo[bufnr].buftype ~= "" then
          return false
        end
        if vim.api.nvim_buf_get_name(bufnr):match("^octo://") then
          return false
        end
        return true
      end

      local function run_lint(bufnr, force)
        if not lintable(bufnr) then
          return
        end
        local tick = vim.b[bufnr].changedtick
        if not force and last_lint[bufnr] == tick then
          return
        end
        last_lint[bufnr] = tick
        vim.api.nvim_buf_call(bufnr, function()
          lint.try_lint()
        end)
      end

      local function debounced_lint(bufnr, delay, force)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        delay = delay or 300

        if buffer_timers[bufnr] then
          buffer_timers[bufnr]:stop()
          buffer_timers[bufnr] = nil
        end

        buffer_timers[bufnr] = vim.defer_fn(function()
          run_lint(bufnr, force)
          buffer_timers[bufnr] = nil
        end, delay)
      end

      -- Create autogroup only once (not cleared on reload)
      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

      -- Lint on save (immediate, no debounce needed)
      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function(args)
          run_lint(args.buf, true)
        end,
        group = lint_augroup,
      })

      -- BufEnter: once per focus; skip if buffer text unchanged since last lint.
      -- (CursorHold + BufReadPost both fired on focus/open and CursorHold repeats every updatetime.)
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function(args)
          debounced_lint(args.buf, 200, false)
        end,
        group = lint_augroup,
      })

      vim.api.nvim_create_autocmd("TextChanged", {
        callback = function(args)
          debounced_lint(args.buf, 500, false)
        end,
        group = lint_augroup,
      })

      -- Clean up timers when buffer is deleted
      vim.api.nvim_create_autocmd("BufDelete", {
        callback = function(args)
          if buffer_timers[args.buf] then
            buffer_timers[args.buf]:stop()
            buffer_timers[args.buf] = nil
          end
          local entry = lint_progress[args.buf]
          if entry then
            entry.handle:finish()
            lint_progress[args.buf] = nil
          end
          last_lint[args.buf] = nil
        end,
        group = lint_augroup,
      })
    end,
  },
}
