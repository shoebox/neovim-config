return {
  {
    "nvim-mini/mini.hipatterns",
    event = "BufReadPre",
    opts = {
      highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

        -- Gherkin
        ggiven = { pattern = "// Given:", group = "MiniPatternsGherkin" },
        gwhen = { pattern = "// When:", group = "MiniPatternsGherkin" },
        gthen = { pattern = "// Then:", group = "MiniPatternsGherkin" },
        gand = { pattern = "// And:", group = "MiniPatternsGherkin" },
        gbut = { pattern = "// But:", group = "MiniPatternsGherkin" },
        nolint = { pattern = "//nolint:", group = "MiniHipattersNote" },
      },
    },
  },
  {
    "nvim-mini/mini.align",
    opts = {},
    keys = {
      { "ga", mode = { "n", "v" }, desc = "Align" },
      { "gA", mode = { "n", "v" }, desc = "Align with preview" },
    },
  },
  {
    "nvim-mini/mini.comment",
    opts = {
      mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        -- Normal and Visual modes
        comment = "<leader>/",

        -- Toggle comment on current line
        comment_line = "<leader>/",

        -- Toggle comment on visual selection
        comment_visual = "<leader>/",

        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        -- Works also in Visual mode if mapping differs from `comment_visual`
        textobject = "gc",
      },
    },
    keys = {
      { "<leader>/", mode = { "n", "v" }, desc = "Comment line or visual selection" },
    },
  },
  -- {
  --   "nvim-mini/mini.tabline",
  --   event = "VeryLazy",
  --   opts = {
  --     tabpage_section = "none",
  --     format = function(buf_id, label)
  --       return " " .. require("mini.tabline").default_format(buf_id, label) .. " "
  --     end,
  --   },
  -- },
  {
    "nvim-mini/mini-git",
    config = function()
      require("mini.git").setup()
    end,
    cmd = "Git",
    keys = {
      {
        "<leader>gc",
        "<cmd>Git commit<cr>",
        mode = { "n" },
        desc = "Mini.nvim - Git commit",
      },
    },
  },
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
  },
  {
    "nvim-mini/mini.splitjoin",
    opts = {
      mappings = {
        toggle = "st",
        split = "ss",
        join = "sj",
      },
    },
    keys = {
      { "st", mode = { "n", "v" }, desc = "Split/Join toggle" },
      { "ss", mode = { "n", "v" }, desc = "Split" },
      { "sj", mode = { "n", "v" }, desc = "Join" },
    },
  },
  {
    "nvim-mini/mini.trailspace",
    opts = {},
    keys = {
      {
        "<leader>ts",
        mode = { "n", "v" },
        desc = "Trim trailing space",
        function()
          MiniTrailspace.trim()
        end,
      },
      {
        "<leader>tl",
        mode = { "n", "v" },
        desc = "Trim trailing space last lines",
        function()
          MiniTrailspace.trim_last_lines()
        end,
      },
    },
  },
}
