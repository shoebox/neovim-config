return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local function get_arguments()
        local co = coroutine.running()
        if co then
          return coroutine.create(function()
            local args = {}
            vim.ui.input({ prompt = "Args: " }, function(input)
              args = vim.split(input or "", " ")
            end)
            coroutine.resume(co, args)
          end)
        else
          local args = {}
          vim.ui.input({ prompt = "Args: " }, function(input)
            args = vim.split(input or "", " ")
          end)
          return args
        end
      end

      local dap = require("dap")
      dap.adapters.delve = {
        type = "server",
        port = "${port}",
        executable = {
          command = "dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
        },
      }

      -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
      dap.configurations.go = {
        {
          type = "delve",
          name = "Debug",
          request = "launch",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Debug (Arguments)",
          request = "launch",
          program = "${file}",
          args = get_arguments,
        },
        {
          type = "delve",
          name = "Debug test", -- configuration for debugging test files
          request = "launch",
          mode = "test",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Debug test (go.mod)",
          request = "launch",
          mode = "test",
          program = "./${relativeFileDirname}",
        },
      }
    end,
    keys = {
      {
        "<F2>",
        function()
          require("dap").step_over()
        end,
        desc = "Nvim-DAP step-over",
      },
      {
        "<F3>",
        function()
          require("dap").step_into()
        end,
        desc = "Nvim-DAP step-into",
      },
      {
        "<F4>",
        function()
          require("dap").step_out()
        end,
        desc = "Nvim-DAP step-out",
      },
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Nvim-DAP continue debugging",
      },
      {
        "<leader>b",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Nvim-DAP toggle breakpoint",
      },
      {
        "<leader>B",
        function()
          require("dap").set_breakpoint()
        end,
        desc = "Nvim-DAP set breakpoint",
      },
      {
        "<leader>lp",
        function()
          require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = "Nvim-DAP log point message",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Nvim-DAP open REPL debug console",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Nvim-DAP debug last run",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Nvim-DAP debug last run",
      },
    },
  },
}
