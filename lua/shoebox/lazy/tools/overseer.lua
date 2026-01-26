return {
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerOpen", "OverseerClose", "OverseerInfo" },
    enabled = false,
    opts = {
      task_list = {
        default_detail = 2,
        width = 600,
      },
      templates = { "builtin", "user.go_build", "user.nix_build" },
      log = {
        {
          type = "notify",
          level = vim.log.levels.DEBUG,
        },
      },
      component_aliases = {
        default = {
          {
            "display_duration",
            detail_level = 2,
          },
          {
            "on_complete_dispose",
            require_view = { "SUCCESS", "FAILURE" },
          },
          {
            "on_output_parse",
            parser = {
              diagnostics = {
                { "extract", "^([^%s].+):(%d+): (.+)$", "filename", "lnum", "text" },
              },
            },
          },
          "default",
          "display_duration",
          "on_output_summarize",
          "on_exit_set_status",
          "on_complete_notify",
          -- "stdout_to_fidget",
        },
      },

      strategy = {
        "terminal",
      },
    },
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "rcarriga/nvim-notify",
    },
    keys = {
      {
        "<leader>ot",
        function()
          require("overseer").toggle()
        end,
        desc = "Overseer - Toggle the running task list",
      },
      {
        "<leader>or",
        "<cmd>OverseerRun<CR>",
        desc = "Overseer - Opens the tasks list",
      },
    },
  },
}
