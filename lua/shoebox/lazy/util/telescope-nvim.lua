return {
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "vertical",
          layout_config = {
            vertical = { width = 0.65 },
          },
          mappings = {
            i = {
              ["<esc>"] = require("telescope.actions").close,
            },
          },
          sorting_strategy = "ascending",
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              layout_strategy = "cursor",
              layout_config = { width = 0.33, height = 0.25 },
            }),
          },
        },
        layout_strategy = "vertical",
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })
    end,
    cmd = "Telescope",
    keys = {
      {
        "<leader>p",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Telescope - live grep",
      },
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Telescope - Find files",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").git_files()
        end,
        desc = "Telescope - Git files",
      },
      {
        "<leader>ca",
        function()
          require("telescope").load_extension("ui-select")
          vim.lsp.buf.code_action()
        end,
        mode = { "n", "v" },
        desc = "Telescope - Code actions",
      },
      {
        "<C-Q>",
        function()
          require("telescope.builtin").quickfix()
        end,
        desc = "Telescope - quickfix",
      },
      {
        "<leader>fm",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = { "method", "function" },
          })
        end,
        desc = "Telescope - Document symbols",
      },
    },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-ui-select.nvim", lazy = true },
    },
  },
}
