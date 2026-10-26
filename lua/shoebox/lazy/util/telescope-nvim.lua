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
      -- {
      --   "<leader>gs",
      --   function()
      --     local action_state = require("telescope.actions.state")
      --     local cur = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
      --     require("telescope.builtin").git_status({
      --       layout_strategy = "horizontal",
      --       previewer = require("telescope.previewers").new_termopen_previewer({
      --         get_command = function(entry)
      --           if entry.status == "??" then
      --             return { "delta", "--paging=never", "/dev/null", entry.value }
      --           end
      --           return {
      --             "env",
      --             "GIT_PAGER=delta --paging=never",
      --             "git",
      --             "diff",
      --             "HEAD",
      --             "--",
      --             entry.value,
      --           }
      --         end,
      --       }),
      --       attach_mappings = function(prompt_bufnr)
      --         local picker = action_state.get_current_picker(prompt_bufnr)
      --         picker:register_completion_callback(function(self)
      --           for i = 1, self.manager:num_results() do
      --             if self.manager:get_entry(i).path == cur then
      --               self:set_selection(self:get_row(i))
      --               return
      --             end
      --           end
      --         end)
      --         return true
      --       end,
      --     })
      --   end,
      --   desc = "Telescope - Git status (delta)",
      -- },
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
