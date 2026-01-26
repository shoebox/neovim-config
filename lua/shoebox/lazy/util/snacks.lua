return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      indent = {
        char = "╎",
        enabled = true,
        animate = {
          enabled = false,
        },
      },
      lazygit = {
        theme = {
          activeBorderColor = { fg = "Constant", bold = true },
          inactiveBorderColor = { fg = "Comment", bold = true },
        },
      },
      scratch = {
        height = 50,
      },
    },
    keys = {
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Snacks - Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Snacks - Select Scratch Buffer",
      },
    },
  },
}
