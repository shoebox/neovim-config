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
  -- {
  --   "lukas-reineke/headlines.nvim",
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter",
  --     -- "cathaysia/tree-sitter-asciidoc",
  --   },
  --   config = function()
  --     -- require("headlines").setup({
  --     --   asciidoc = {
  --     --     query = vim.treesitter.query.parse(
  --     --       "asciidoc",
  --     --       [[
  --     --           [
  --     --               (title_h0_marker)
  --     --               (title_h1_marker)
  --     --               (title_h2_marker)
  --     --               (title_h3_marker)
  --     --               (title_h4_marker)
  --     --               (title_h5_marker)
  --     --           ] @headline
  --     --       ]]
  --     --     ),
  --     --     headline_highlights = { "headline" },
  --     --     bullet_highlights = { "Demo" },
  --     --     bullets = { "◉", "○", "✸", "✿" },
  --     --     dash_string = "*",
  --     --     quote_highlight = "Quote",
  --     --     quote_string = "┃ ",
  --     --     fat_headlines = false,
  --     --     fat_headline_upper_string = "▄",
  --     --     fat_headline_lower_string = "▀",
  --     --   },
  --     -- })
  --   end,
  --   ft = { "asciidoc", "adoc", "loongdoc" },
  -- },
  -- Markdown
  {
    "iamcco/markdown-preview.nvim",
    event = "VeryLazy",
    ft = { "markdown", "md" },
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  },
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
