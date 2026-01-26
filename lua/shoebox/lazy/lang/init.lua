return {
  {
    "mfussenegger/nvim-ansible",
    enabled = false,
    ft = "yaml.ansible",
  },
  {
    "LnL7/vim-nix",
    ft = "nix",
  },
  {
    "fei6409/log-highlight.nvim",
    event = "BufRead *.log",
    opts = {},
  },
  -- Markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      -- "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.icons",
    },
    ft = {
      "md",
      "markdown",
      "Avante",
      "codecompanion",
    },
    opts = {
      file_types = { "asciidoc", "md", "markdown", "Avante", "codecompanion" },
      bullet = {
        left_pad = 1,
        right_pad = 0,
      },
      heading = {
        right_pad = 1,
      },
    },
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
