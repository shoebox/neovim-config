return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false, -- indent/bigfile/quickfile autocmds must exist before the first BufRead
    opts = {
      -- Fidget owns vim.notify (override_vim_notify). Snacks notifier replaces it on setup.
      notifier = { enabled = false },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      -- enabled = false: UIEnter would require the picker module. Keymaps load it.
      picker = {
        enabled = false,
        sources = {
          gh_pr = {
            layout = { preset = "default", layout = { width = 0, height = 0 } },
          },
          gh_issue = {
            layout = { preset = "default", layout = { width = 0, height = 0 } },
          },
          gh_diff = {
            layout = { preset = "default", layout = { width = 0, height = 0 } },
          },
        },
      },
      indent = {
        char = "╎",
        enabled = true,
        animate = {
          enabled = false,
        },
      },
      lazygit = {
        theme = {
          activeBorderColor = { fg = "Constant", bold = true },
          inactiveBorderColor = { fg = "Comment", bold = true },
        },
        win = {
          width = 0,
          height = 0,
        },
        -- -- Override snacks defaults (nvim-remote → Cursor/new tab). Use RPC into this instance.
        -- config = {
        --   -- os = {
        --   --   editPreset = "",
        --   --   edit = vim.fn.stdpath("config") .. "/scripts/lazygit-open {{filename}}",
        --   --   editAtLine = vim.fn.stdpath("config") .. "/scripts/lazygit-open {{filename}} {{line}}",
        --   --   editInTerminal = false,
        --   -- },
        -- },
      },
      scratch = {
        height = 50,
      },
    },
    keys = {
      {
        "<leader>gi",
        function()
          Snacks.picker.gh_issue()
        end,
        desc = "GitHub Issues (open)",
      },
      {
        "<leader>gI",
        function()
          Snacks.picker.gh_issue({ state = "all" })
        end,
        desc = "GitHub Issues (all)",
      },
      {
        "<leader>gp",
        function()
          Snacks.picker.gh_pr()
        end,
        desc = "GitHub Pull Requests (open)",
      },
      {
        "<leader>gP",
        function()
          Snacks.picker.gh_pr({ state = "all" })
        end,
        desc = "GitHub Pull Requests (all)",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Snacks - Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Snacks - Select Scratch Buffer",
      },
    },
  },
}
