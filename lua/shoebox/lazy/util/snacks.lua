return {
  {
    "folke/snacks.nvim",
    lazy = true,
    opts = {
      indent = {
        chunk = {
          enabled = false,
        },
        scope = {},
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
