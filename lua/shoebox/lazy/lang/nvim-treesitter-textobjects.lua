local function select_textobject(textobject)
  return function()
    require("nvim-treesitter-textobjects.select").select_textobject(textobject, "textobjects")
  end
end

local function goto_next_start(textobject)
  return function()
    require("nvim-treesitter-textobjects.move").goto_next_start(textobject)
  end
end

local function goto_previous_start(textobject)
  return function()
    require("nvim-treesitter-textobjects.move").goto_previous_start(textobject)
  end
end

local function goto_next_end(textobject)
  return function()
    require("nvim-treesitter-textobjects.move").goto_next_end(textobject)
  end
end

local function goto_previous_end(textobject)
  return function()
    require("nvim-treesitter-textobjects.move").goto_previous_end(textobject)
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
    branch = "main",
    requires = "nvim-treesitter/nvim-treesitter",
    keys = {
      { "af", select_textobject("@function.outer"), mode = { "x", "o" }, desc = "Around function" },
      { "if", select_textobject("@function.inner"), mode = { "x", "o" }, desc = "Inside function" },
      {
        "as",
        select_textobject("@class.outer"),
        mode = { "x", "o" },
        desc = "Around struct/class",
      },
      {
        "is",
        select_textobject("@class.inner"),
        mode = { "x", "o" },
        desc = "Inside struct/class",
      },
      {
        "]f",
        goto_next_start("@function.outer"),
        mode = { "n", "x", "o" },
        desc = "Next function start",
      },
      {
        "[f",
        goto_previous_start("@function.outer"),
        mode = { "n", "x", "o" },
        desc = "Previous function start",
      },
      {
        "]F",
        goto_next_end("@function.outer"),
        mode = { "n", "x", "o" },
        desc = "Next function end",
      },
      {
        "[F",
        goto_previous_end("@function.outer"),
        mode = { "n", "x", "o" },
        desc = "Previous function end",
      },
      {
        "]s",
        goto_next_start("@class.outer"),
        mode = { "n", "x", "o" },
        desc = "Next struct/class start",
      },
      {
        "[s",
        goto_previous_start("@class.outer"),
        mode = { "n", "x", "o" },
        desc = "Previous struct/class start",
      },
    },
    opts = {
      select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        looahead = true,

        selection_modes = {
          ["@parameter.outer"] = "v", -- charwise
          ["@function.outer"] = "V", -- linewise
          ["@class.outer"] = "V", -- linewise
        },

        keymaps = {},
      },
    },
  },
}
