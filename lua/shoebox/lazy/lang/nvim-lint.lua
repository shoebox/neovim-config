local vim = vim

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Configure linters by filetype
      lint.linters_by_ft = {
        ansible = { "ansible_lint" },
        dockerfile = { "hadolint" },
        go = { "golangcilint" },
        lua = { "luacheck" },
        nix = { "deadnix" },
        yaml = { "yamllint" },
        ["yaml.githubworkflow"] = { "actionlint" },
      }

      -- Debounced lint function to avoid excessive linting
      local lint_timer = nil
      local function debounced_lint()
        if lint_timer then
          vim.fn.timer_stop(lint_timer)
        end
        lint_timer = vim.fn.timer_start(100, function()
          lint.try_lint()
          lint_timer = nil
        end)
      end

      -- Optimized autocommand setup
      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
      -- Lint on save (immediate)
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      -- Lint on cursor hold (debounced for performance)
      vim.api.nvim_create_autocmd("CursorHold", {
        group = lint_augroup,
        callback = function()
          -- Only lint if the buffer has a supported filetype
          local ft = vim.bo.filetype
          if lint.linters_by_ft[ft] then
            debounced_lint()
          end
        end,
      })

      -- Lint when entering a buffer (debounced)
      vim.api.nvim_create_autocmd("BufEnter", {
        group = lint_augroup,
        callback = function()
          -- Only lint if the buffer has a supported filetype
          local ft = vim.bo.filetype
          if lint.linters_by_ft[ft] then
            debounced_lint()
          end
        end,
      })
    end,
  },
}
