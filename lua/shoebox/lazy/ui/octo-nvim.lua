return {
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "Octo", "OctoShards" },
    keys = {
      -- {
      --   "<leader>oi",
      --   "<CMD>Octo issue list<CR>",
      --   desc = "List GitHub Issues",
      -- },
      {
        "<leader>op",
        "<CMD>Octo pr list<CR>",
        desc = "List GitHub PullRequests",
      },
      -- {
      --   "<leader>od",
      --   "<CMD>Octo discussion list<CR>",
      --   desc = "List GitHub Discussions",
      -- },
      {
        "<leader>on",
        "<CMD>Octo notification list<CR>",
        desc = "List GitHub Notifications",
      },
      {
        "<leader>os",
        function()
          require("octo.utils").create_base_search_command({ include_current_repo = true })
        end,
        desc = "Search GitHub",
      },
    },
    opts = {
      github_hostname = "github.com",
      ssh_aliases = { ["nbcugithub.com"] = "github.com" },
    },
    config = function(_, opts)
      require("octo").setup(opts)
      require("octo-shards").setup()

      -- Confirm before closing the review tab so a stray <C-c>/<esc> muscle
      -- memory doesn't nuke the whole review session.
      local mappings = require("octo.mappings")
      local orig_close_review_tab = mappings.close_review_tab
      mappings.close_review_tab = function()
        if vim.fn.confirm("Close review tab?", "&Yes\n&No", 2) == 1 then
          orig_close_review_tab()
        end
      end

      -- Strip full-line diff backgrounds in Octo review windows so real
      -- syntax highlighting shows through, and show a thin gutter bar
      -- (via extmark signs) as the only add/remove/change indicator.
      local c = require("octo.constants")
      local diff_groups = { "DiffAdd", "DiffDelete", "DiffChange", "DiffText" }
      for _, ns in ipairs({ c.OCTO_REVIEW_LEFT_HIGHLIGHT_NS, c.OCTO_REVIEW_RIGHT_HIGHLIGHT_NS }) do
        for _, g in ipairs(diff_groups) do
          vim.api.nvim_set_hl(ns, g, { bg = "NONE", fg = "NONE" })
        end
      end
      vim.api.nvim_set_hl(
        c.OCTO_REVIEW_LEFT_HIGHLIGHT_NS,
        "OctoReviewDiffDeleteText",
        { bg = "NONE", fg = "NONE", underline = true }
      )
      vim.api.nvim_set_hl(
        c.OCTO_REVIEW_RIGHT_HIGHLIGHT_NS,
        "OctoReviewDiffAddText",
        { bg = "NONE", fg = "NONE", underline = true }
      )

      -- Link with a hardcoded fallback so signs stay visible even if
      -- GitSigns hasn't loaded yet or its groups aren't defined.
      vim.api.nvim_set_hl(0, "OctoSignAdd", { link = "GitSignsAdd", default = true })
      vim.api.nvim_set_hl(0, "OctoSignDelete", { link = "GitSignsDelete", default = true })
      vim.api.nvim_set_hl(0, "OctoSignChange", { link = "GitSignsChange", default = true })

      local sign_ns = vim.api.nvim_create_namespace("octo_diff_signs")

      local function refresh_win(win)
        if not vim.api.nvim_win_is_valid(win) then
          return
        end
        local buf = vim.api.nvim_win_get_buf(win)
        if not vim.api.nvim_buf_get_name(buf):match("^octo://") then
          return
        end
        vim.api.nvim_buf_clear_namespace(buf, sign_ns, 0, -1)
        if not vim.wo[win].diff then
          return
        end
        pcall(vim.api.nvim_set_option_value, "signcolumn", "yes", { win = win })
        vim.api.nvim_win_call(win, function()
          for lnum = 1, vim.api.nvim_buf_line_count(buf) do
            local name = vim.fn.synIDattr(vim.fn.diff_hlID(lnum, 1), "name")
            local hl = (name == "DiffAdd" and "OctoSignAdd")
              or (name == "DiffDelete" and "OctoSignDelete")
              or ((name == "DiffChange" or name == "DiffText") and "OctoSignChange")
              or nil
            if hl then
              vim.api.nvim_buf_set_extmark(buf, sign_ns, lnum - 1, 0, {
                sign_text = "▎",
                sign_hl_group = hl,
              })
            end
          end
        end)
      end

      local function refresh_all()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          vim.schedule(function()
            refresh_win(win)
          end)
        end
      end

      vim.api.nvim_create_autocmd("DiffUpdated", { callback = refresh_all })
      vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
        pattern = "octo://*",
        callback = refresh_all,
      })
    end,
  },
}
