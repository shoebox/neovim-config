local vim = vim

return {
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      local lint = require("lint")

      -- Configure linters by filetype
      lint.linters_by_ft = {
        dockerfile = { "hadolint" },
        go = { "golangcilint" },
        lua = { "luacheck" },
        nix = { "deadnix" },
        yaml = { "yamllint" },
        ["yaml.githubworkflow"] = { "actionlint", "yamllint" },
        ["yaml.ansible"] = { "yamllint" },
      }

      local buffer_timers = {}
      local lint_handles = {} -- Track fidget progress handles per buffer

      local function debounced_lint(bufnr, delay)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        delay = delay or 100

        -- Cancel existing timer for this buffer
        if buffer_timers[bufnr] then
          buffer_timers[bufnr]:stop()
          buffer_timers[bufnr] = nil
        end

        -- Create new timer using vim.uv (faster than vim.fn.timer_start)
        buffer_timers[bufnr] = vim.defer_fn(function()
          local timer_bufnr = bufnr -- Explicit closure capture for clarity

          -- Verify buffer is still valid before linting
          if vim.api.nvim_buf_is_valid(timer_bufnr) then
            lint.try_lint()
          end

          buffer_timers[timer_bufnr] = nil
        end, delay)
      end

      -- Create autogroup only once (not cleared on reload)
      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

      -- Lint on save (immediate, no debounce needed)
      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function(args)
          lint.try_lint()
        end,
        group = lint_augroup,
      })

      vim.api.nvim_create_autocmd({ "CursorHold", "BufReadPost" }, {
        callback = function(args)
          debounced_lint(args.buf, 100)
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
          if lint_handles[args.buf] then
            lint_handles[args.buf]:cancel()
            lint_handles[args.buf] = nil
          end
        end,
        group = lint_augroup,
      })

      -- Listen for diagnostic changes to finish progress
      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        callback = function(args)
          if not lint_handles[args.buf] then
            return
          end
        end,
        group = lint_augroup,
      })
    end,
  },
}
