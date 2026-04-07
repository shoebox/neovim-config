return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      -- "nvim-treesitter/nvim-treesitter",
      -- "echasnovski/mini.icons",
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
        left_pad = 2,
        right_pad = 1,
      },
      checkbox = {
        left_pad = 2,
      },
      heading = {
        border = true,
        right_pad = 1,
      },
    },
  },
}
