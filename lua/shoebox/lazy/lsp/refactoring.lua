return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- prompt for return type
      prompt_func_return_type = {
        go = true,
        cpp = true,
        c = true,
        java = true,
      },
      -- prompt for function parameters
      prompt_func_param_type = {
        go = true,
        cpp = true,
        c = true,
        java = true,
      },
    },
    keys = {
      {
        "<leader>re",
        function()
          require("refactoring").select_refactor()
        end,
        desc = "Refactoring.nvim",
        mode = { "v", "n" },
      },
    },
  },
}
