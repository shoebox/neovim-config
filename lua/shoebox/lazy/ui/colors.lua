local function MyColorScheme(color)
  color = color or "eldritch"
  vim.cmd.colorscheme(color)
end

-- Remove the background color for LspInlayHint
vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#969696", bg = "NONE" })

return {
  {
    "eldritch-theme/eldritch.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      dim_inactive = false,
      transparent = false,
      hide_inactive_statusline = true,
      lualine_bold = true,
      on_highlights = function(hl, colors)
        hl.WinSeparator = { fg = colors.bg_dark, bg = nil }
        hl.VertSplit = { fg = colors.fg_gutter, bg = nil }

        -- line numbers
        hl.LineNr = { fg = colors.dark5, bg = nil, bold = true }
        hl.CursorLineNr = { fg = colors.fg_dark, bg = nil, bold = true }

        hl.MiniHipatternsNote = { bg = colors.bg_dark, fg = colors.green, bold = false }
        hl.MiniHipatternsFixme = { bg = colors.bg_dark, fg = colors.red, bold = false }
        hl.MiniPatternsGherkin = { bg = colors.bg_dark, fg = colors.dark3, bold = true }
        hl.MiniHipattersNote = { fg = colors.dark5, bg = nil, bold = false }

        -- neo-tree
        hl.NeoTreeNormal = { bg = colors.bg_dark }
        hl.NvimTreeOpenedFile = { fg = colors.dark3, bg = colors.cyan }
        hl.NeoTreeDirectoryName = { fg = colors.dark3, bg = nil }
        hl.NeoTreeFileName = { fg = colors.cyan, bg = nil }
        hl.NeoTreeDimText = { fg = colors.dark5, bg = nil }

        -- neotest
        hl.NeotestIndent = { fg = colors.dark5, bg = nil }
        hl.NeotestAdapterName = { bg = colors.bg_dark, fg = colors.dark5 }
        hl.NeoTestExpandMarker = { fg = colors.dark5, bg = nil }
        hl.NeotestExpandMarker = { fg = colors.dark5, bg = nil }
        hl.NeotestTest = { fg = colors.dark3, bg = nil }
        hl.NeotestFocused = { fg = colors.green, bg = nil }
        hl.NeotestFile = { fg = colors.dark5, bg = nil }
        hl.NeotestDir = { fg = colors.dark3, bg = nil }
        hl.NeotestNamespace = { fg = colors.cyan, bg = nil }
        hl.NeotestFailed = { fg = nil, bg = colors.red }
        hl.NeotestUnknown = { fg = colors.dark5, bg = nil }

        hl.TabLineSel = { fg = colors.green, bg = colors.green }
        hl.WildMenu = { fg = colors.green, bg = colors.green }

        -- telescope
        hl.TelescopePromptBorder = { fg = colors.dark5, bg = nil }
        hl.TelescopeResultsBorder = { fg = colors.dark5, bg = nil }
        hl.TelescopePreviewBorder = { fg = colors.dark3, bg = nil }
        hl.TelescopeTitle = { fg = colors.green, bg = nil }

        -- indent
        hl.SnacksIndent = { fg = colors.dark5, bg = nil }
        hl.SnacksIndentScope = { fg = colors.dark_cyan, bg = nil }
      end,
    },
    init = function()
      MyColorScheme()
    end,
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      dim_inactive = false,
      style = "storm",
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        hl.Normal = "Foo"
        local prompt = "#2d3149"
        hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg }
        hl.TelescopeBorder = { bg = c.bg_dark, fg = c.bg_dark }
        hl.TelescopePromptNormal = { bg = prompt }
        hl.TelescopePromptBorder = { bg = prompt, fg = prompt }
        hl.TelescopePromptTitle = { bg = c.fg_gutter, fg = c.orange }
        hl.TelescopePreviewTitle = { bg = c.bg_dark, fg = c.bg_dark }
        hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }
      end,
      terminal_colors = true,
      -- transparent = true,
    },
    lazy = true,
  },
  {
    "olimorris/onedarkpro.nvim",
    enabled = false,
    opts = {
      highlights = {
        Comment = { italic = true },
        Directory = { bold = true },
        ErrorMsg = { italic = true, bold = true },
      },
      options = {
        cursorline = true, -- Use cursorline highlighting?
        transparency = false, -- Use a transparent background?
        terminal_colors = true, -- Use the theme's colors for Neovim's :terminal?
        lualine_transparency = true, -- Center bar transparency?
        highlight_inactive_windows = false, -- When the window is out of focus, change the normal background?
      },
    },
    lazy = true,
  },
  {
    "loctvl842/monokai-pro.nvim",
    enabled = false,
    opts = {},
    lazy = true,
  },
  {
    "catppuccin/nvim",
    enabled = false,
    lazy = true,
    name = "catppuccin",
    opts = {},
  },
  {
    "EdenEast/nightfox.nvim",
    enabled = false,
    opts = {},
    lazy = true,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    enabled = false,
    lazy = true,
  },
}
