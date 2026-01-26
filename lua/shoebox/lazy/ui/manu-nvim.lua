return {
 {
    "bassamsdata/namu.nvim",
    keys = {
      {
        "<C-t>",
        function()
          require("namu.namu_symbols").show()
        end,
        mode = { "n", "x", "o" },
        desc = "Show symbols in current file",
      },
      {
        "<C-e>",
        function()
          require("namu.namu_workspace").show()
        end,
        mode = { "n", "x", "o" },
        desc = "Show symbols in workspace",
      },
    },
    opts = {
      namu_symbols = {
        enable = true,
        options = {
          preview = {
            highlight_on_move = false,
          },
          auto_seelect = false,
        },
      },
      ui_select = { enable = false }, -- vim.ui.select() wrapper
    },
  },
}
