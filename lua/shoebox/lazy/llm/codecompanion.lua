vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "COMMIT_EDITMSG",
  callback = function(args)
    local bufnr = args.buf
    -- Check if we've already shown the prompt in this buffer
    if vim.b[bufnr].commit_prompt_shown then
      return
    end
    vim.b[bufnr].commit_prompt_shown = true
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.cmd("CodeCompanion /conventional_commit")
      end
    end, 50)
  end,
})

return {
  {
    "olimorris/codecompanion.nvim",
    cmd = {
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanion",
    },
    dependencies = {
      "github/copilot.vim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<leader>za",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v", "x" },
        desc = "Code Companion - Actions",
      },
      {
        "<leader>]",
        mode = { "n", "v" },
        "<cmd>CodeCompanionActions<cr>",
        desc = "Code Companion - Actions",
      },
      {
        "<leader>zc",
        "<cmd>CodeCompanionChat<cr>",
        desc = "Code Companion - Chat",
      },
    },
    opts = {
      adapters = {
        http = {
          opts = {
            show_defaults = false,
          },
        },
      },
      prompt_library = {
        markdown = {
          dirs = {
            vim.fn.stdpath("config") .. "/lua/shoebox/llm/prompts/",
            vim.fn.stdpath("config") .. "/lua/shoebox/llm/prompts/codereview/",
            vim.fn.stdpath("config") .. "/lua/shoebox/llm/prompts/commit/",
            vim.fn.stdpath("config") .. "/lua/shoebox/llm/prompts/docs/",
            vim.fn.stdpath("config") .. "/lua/shoebox/llm/prompts/refactoring/",
            vim.fn.stdpath("config") .. "/lua/shoebox/llm/prompts/unittests/",
          },
        },
      },
      display = {
        action_palette = {
          opts = {
            show_default_actions = true,
            show_default_prompt_library = false,
            width = 20,
            height = 10,
          },
        },
        chat = {
          window = {
            show_references = false,
            show_header_separator = true,
            show_settings = false,
            width = 0.33,
          },
        },
      },
      memory = {
        opts = {
          chat = {
            enabled = true,
          },
        },
      },
      strategies = {
        chat = {
          adapter = "auggie_cli",
          keymaps = {
            clear = {
              modes = { n = "gxx" },
              index = 6,
              callback = "keymaps.clear",
              description = "Clear Chat",
            },
            debug = {
              modes = {
                n = "gdd",
              },
              index = 16,
              callback = "keymaps.debug",
              description = "View debug info",
            },
          },
        },
        inline = {
          adapter = "copilot",
        },
        cmd = {
          adapter = "auggie_cli",
        },
      },
    },
  },
}
