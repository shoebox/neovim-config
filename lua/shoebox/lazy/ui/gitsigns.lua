return {
  {
    "lewis6991/gitsigns.nvim",
    cmd = "Gitsigns",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "VeryLazy" },
    opts = {
      attach_to_untracked = false,
    },
  },
}
