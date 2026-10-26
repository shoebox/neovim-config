return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      extensions = {
        "lazy",
        -- "toggleterm",
        -- "neo-tree",
        -- "quickfix",
        -- "trouble",
      },
      sections = {
        lualine_a = {
          { "mode" },
        },
        lualine_b = {
          { "filename", color = { gui = "bold" } },
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
        },
        lualine_x = {},
        lualine_y = { { "branch", icon = "" } },
        lualine_z = { { "datetime", style = " %X" } },
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
