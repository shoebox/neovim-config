return {
  {
    "LnL7/vim-nix",
    ft = "nix",
  },
  {
    "fei6409/log-highlight.nvim",
    event = "BufRead *.log",
    opts = {},
  },
  -- General
  {
    "andythigpen/nvim-coverage",
    enabled = false,
    event = "BufReadPost",
    version = "*",
    config = function()
      require("coverage").setup({
        auto_reload = true,
      })
    end,
  },
}
