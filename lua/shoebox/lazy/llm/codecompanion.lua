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
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    enabled = false,
    keys = {
      {
        "<C-\\>",
        function()
          require("codecompanion").toggle_chat()
        end,
        mode = { "n", "v", "i" },
        desc = "Toggle Code Companion Chat",
      },
      {
        "<leader>zx", -- ported from agentic.nvim's cursor-acp session shortcut
        function()
          require("codecompanion").chat({ params = { adapter = "cursor_cli" } })
        end,
        mode = { "n", "v" },
        desc = "Code Companion - Chat (Cursor CLI)",
      },
    },
    opts = {
      adapters = {
        http = {
          opts = {
            -- Only show adapters we've explicitly configured (was `show_defaults`
            -- pre-rename; renamed upstream to `show_presets`).
            show_presets = false,
          },
        },
        acp = {
          -- Ported from agentic.nvim's acp_providers: Copilot CLI as the
          -- default agent, with `--allow-all-tools` for parity with the old
          -- auto-approval behaviour.
          copilot_acp = function()
            return require("codecompanion.adapters").extend("copilot_acp", {
              commands = {
                default = { "copilot", "--acp", "--stdio", "--allow-all-tools" },
              },
              defaults = {
                -- Let Copilot pick the best model per-request instead of
                -- pinning to whatever it defaulted to (e.g. Claude Sonnet 5).
                session_config_options = {
                  model = "auto",
                },
              },
            })
          end,
          -- Ported from agentic.nvim's cursor-acp provider. The installed CLI
          -- binary is `cursor-agent`, not the newer `agent` the preset assumes.
          cursor_cli = function()
            return require("codecompanion.adapters").extend("cursor_cli", {
              commands = {
                default = { "cursor-agent", "acp" },
              },
            })
          end,
        },
      },
      display = {
        action_palette = {
          opts = {
            show_preset_actions = true,
            show_preset_prompts = true,
            title = "How can I help?",
          },
          width = 100,
          height = 10,
          provider = "snacks",
        },
        chat = {
          window = {
            position = "right",
            show_header_separator = true,
            show_settings = false,
            width = 0.33,
          },
        },
      },
      interactions = {
        chat = {
          adapter = "cursor_cli",
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
            -- Ported from agentic.nvim's `<localLeader>m` switch_model keymap.
            -- Reuses the built-in `ga` picker, which lets you choose both the
            -- agent/adapter (copilot_acp, cursor_cli, auggie_cli...) and model.
            switch_model = {
              modes = { n = "<localLeader>m" },
              index = 15,
              callback = "keymaps.change_adapter",
              description = "Switch agent/model",
            },
          },
        },
        inline = {
          adapter = "ollama",
        },
        cmd = {
          adapter = "auggie_cli",
        },
      },
    },
  },
}
