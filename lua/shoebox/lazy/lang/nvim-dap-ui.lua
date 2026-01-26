return {
  {
    "rcarriga/nvim-dap-ui",
    opts = {},
    keys = {
      {
        "<leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
      },
      {
        "<leader>dp",
        function()
          require("dap.ui.widgets").preview()
        end,
      },
      {
        "<leader>df",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.frames)
        end,
      },
      {
        "<leader>ds",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.scopes)
        end,
        desc = "DAPUI - Display scopes",
      },
      {
        "<leader>do",
        function()
          require("dapui").open()
        end,
        desc = "DAPUI - Open",
      },
      {
        "<leader>dc",
        function()
          require("dapui").close()
        end,
        desc = "DAPUI - Close",
      },
    },
  },
}
