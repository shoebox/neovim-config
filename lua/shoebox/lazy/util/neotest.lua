local vim = vim

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "fredrikaverpil/neotest-golang",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      -- get neotest namespace (api call creates or returns namespace)
      local neotest_ns = vim.api.nvim_create_namespace("neotest")

      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message =
              diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      local neotest = require("neotest")
      -- Golang
      neotest.setup({
        adapters = {
          require("neotest-golang")({
            testify_enabled = true,
            go_test_args = {
              "-v",
              -- "-race",
              "-count=1",
            },
            warn_test_name_dupes = false,
          }),
        },
        icons = {
          running = "⬜",
          passed = "🟩",
          failed = "🟥",
          skipped = "🟨",
          unknown = "⬜",
        },
        output_panel = {
          enabled = true,
          -- open = "botright split | resize 20 | vertical resize 100",
        },
        status = {
          signs = true,
        },
        summary = {
          animated = true,
          count = true,
        },
      })
    end,
    keys = {
      {
        "<leader>rtf",
        function()
          require("neotest").output_panel.clear()
          require("neotest").run.run()
        end,
        desc = "Neotest - Test function",
      },
      {
        "<leader>rtp",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Neotest - Test function",
      },
      {
        "<leader>rto",
        function()
          require("neotest").output.open()
        end,
        desc = "Neotest - Test function",
      },
      {
        "<leader>rtd",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Neotest - Test function",
      },
      {
        "<leader>rtc",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Neotest - Test class",
      },
      {
        "<leader>rts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Neotest - Toggle summary",
      },
      {
        "<leader>rtw",
        function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end,
        desc = "Neotest - Watch current file",
      },
    },
  },
}
