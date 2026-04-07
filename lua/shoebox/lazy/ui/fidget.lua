return {
  {
    "j-hui/fidget.nvim",
    event = "UIEnter",
    branch = "main",
    config = function()
      require("shoebox.extras.shoeboxfidget").setup_fidget()
    end,
    opts = {
      filter = vim.log.levels.DEBUG,
      override_vim_notify = true,
      window = {
        avoid = { "NvimTree" },
        y_padding = 2,
      },
      view = {
        reflow = true,
        stack_upwards = false,
      },
      progress = {
        ignore_done_already = true,
        ignore_empty_message = true,
      },
    },
  },
}
