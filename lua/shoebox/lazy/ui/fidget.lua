return {
  {
    "j-hui/fidget.nvim",
    event = "UIEnter",
    branch = "main",
    config = function()
      require("shoebox.extras.shoeboxfidget").setup_fidget()
    end,
    opts = {
      integration = {
        ["nvim-tree"] = {
          enable = true, -- Integrate with nvim-tree/nvim-tree.lua (if installed)
        },
      },
      notification = {
        override_vim_notify = true,
        window = {
          y_padding = 2,
        },
        view = {
          reflow = true,
          stack_upwards = false,
        },
      },
    },
  },
}
