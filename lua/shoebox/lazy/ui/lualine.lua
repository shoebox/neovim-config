return {
  {
    "nvim-lualine/lualine.nvim",
    event = "UIEnter",
    opts = {
      extensions = {
        "lazy",
        "toggleterm",
        "neo-tree",
        "quickfix",
        "trouble",
      },
      sections = {
        lualine_a = { { "mode" } },
        lualine_b = {
          { "branch", color = { gui = "bold" }, icon = "" },
        },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
              hint = "󰝶 ",
            },
          },
          { "filename" },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            "datetime",
            style = " %X",
          },
        },
      },
      options = {
        component_separators = "",
        globalstatus = true,
        padding = 1,
        section_separators = { left = "", right = "" },
        theme = "eldritch",
      },
    },
  },
}
