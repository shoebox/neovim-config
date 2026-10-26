return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    enabled = false,
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      -- Ghost-text suggestions replace the old split-window panel; keep it off.
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        gitcommit = true,
        -- Don't trigger inline suggestions inside chat/agent buffers.
        AgenticChat = false,
        AgenticInput = false,
        codecompanion = false,
        codecompanion_input = false,
        codecompanion_cli = false,
      },
    },
  },
}
