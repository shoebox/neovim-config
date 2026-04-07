--- Apply render-markdown.nvim highlights when a markdown-like buffer is first opened.
--- Runs once on the first matching FileType event.
local function apply_markdown_highlights()
  local colors = require("eldritch.colors").setup()
  local hl = function(name, val)
    vim.api.nvim_set_hl(0, name, val)
  end

  -- heading backgrounds
  hl("RenderMarkdownH1Bg", { bg = colors.diff.delete, fg = colors.red })
  hl("RenderMarkdownH2Bg", { bg = colors.bg_highlight, fg = colors.cyan })
  hl("RenderMarkdownH3Bg", { bg = colors.diff.add, fg = colors.green })
  hl("RenderMarkdownH4Bg", { bg = colors.bg_highlight, fg = colors.green })
  hl("RenderMarkdownH5Bg", { bg = colors.bg_highlight, fg = colors.pink })
  hl("RenderMarkdownH6Bg", { bg = colors.bg_highlight, fg = colors.orange })

  -- heading foregrounds
  hl("RenderMarkdownH1", { fg = colors.red, bold = true })
  hl("@markup.heading.1.markdown", { fg = colors.red, bold = true })
  hl("RenderMarkdownH2", { fg = colors.cyan, bold = true })
  hl("@markup.heading.2.markdown", { fg = colors.cyan, bold = true })
  hl("RenderMarkdownH3", { bg = colors.diff.add, fg = colors.green })
  hl("@markup.heading.3.markdown", { fg = colors.green, bold = true })
  hl("RenderMarkdownH4", { fg = colors.green, bold = true })
  hl("@markup.heading.4.markdown", { fg = colors.green, bold = true })
  hl("RenderMarkdownH5", { fg = colors.pink, bold = true })
  hl("@markup.heading.5.markdown", { fg = colors.pink, bold = true })
  hl("RenderMarkdownH6", { fg = colors.orange, bold = true })
  hl("@markup.heading.6.markdown", { fg = colors.orange, bold = true })

  -- code blocks
  hl("RenderMarkdownCode", { bg = colors.bg_dark })
  hl("RenderMarkdownCodeBorder", { bg = colors.bg_dark })
  hl("RenderMarkdownCodeInline", { bg = colors.bg_dark })
  hl("RenderMarkdownCodeInfo", { fg = colors.dark5 })

  -- quotes
  hl("RenderMarkdownQuote", { fg = colors.dark5 })

  -- general
  hl("RenderMarkdownBullet", { fg = colors.cyan })
  hl("RenderMarkdownDash", { fg = colors.dark5 })
  hl("RenderMarkdownLink", { fg = colors.cyan })
  hl("RenderMarkdownLinkTitle", { fg = colors.purple })
  hl("RenderMarkdownWikiLink", { fg = colors.cyan })

  -- checkboxes
  hl("RenderMarkdownUnchecked", { fg = colors.dark5 })
  hl("RenderMarkdownChecked", { fg = colors.green })
  hl("RenderMarkdownTodo", { fg = colors.yellow })

  -- tables
  hl("RenderMarkdownTableHead", { fg = colors.cyan, bold = true })
  hl("RenderMarkdownTableRow", { fg = colors.dark3 })

  -- callouts
  hl("RenderMarkdownSuccess", { fg = colors.green })
  hl("RenderMarkdownInfo", { fg = colors.cyan })
  hl("RenderMarkdownHint", { fg = colors.dark_green })
  hl("RenderMarkdownWarn", { fg = colors.yellow })
  hl("RenderMarkdownError", { fg = colors.red })
end

--- Apply deferred highlight overrides for plugins that are not visible at startup.
--- Runs once after UIEnter via vim.schedule to avoid blocking the initial frame.
local function apply_deferred_highlights()
  local colors = require("eldritch.colors").setup()
  local hl = function(name, val)
    vim.api.nvim_set_hl(0, name, val)
  end

  -- completion
  hl("BlinkCmpSource", { fg = colors.purple })

  -- mini
  hl("MiniHipatternsNote", { bg = colors.bg_dark, fg = colors.green })
  hl("MiniHipatternsFixme", { bg = colors.bg_dark, fg = colors.red })
  hl("MiniPatternsGherkin", { bg = colors.bg_dark, fg = colors.dark3, bold = true })
  hl("MiniHipattersNote", { fg = colors.dark5 })

  -- neo-tree
  hl("NeoTreeNormal", { bg = colors.bg_dark })
  hl("NvimTreeOpenedFile", { fg = colors.dark3, bg = colors.cyan })
  hl("NeoTreeDirectoryName", { fg = colors.dark3 })
  hl("NeoTreeFileName", { fg = colors.cyan })
  hl("NeoTreeDimText", { fg = colors.dark5 })

  -- neotest
  hl("NeotestIndent", { fg = colors.dark5 })
  hl("NeotestAdapterName", { bg = colors.bg_dark, fg = colors.dark5 })
  hl("NeoTestExpandMarker", { fg = colors.dark5 })
  hl("NeotestExpandMarker", { fg = colors.dark5 })
  hl("NeotestTest", { fg = colors.dark3 })
  hl("NeotestFocused", { fg = colors.green })
  hl("NeotestFile", { fg = colors.dark5 })
  hl("NeotestDir", { fg = colors.dark3 })
  hl("NeotestNamespace", { fg = colors.cyan })
  hl("NeotestFailed", { bg = colors.red })
  hl("NeotestUnknown", { fg = colors.dark5 })

  -- telescope
  hl("TelescopePromptBorder", { fg = colors.dark5 })
  hl("TelescopeResultsBorder", { fg = colors.dark5 })
  hl("TelescopePreviewBorder", { fg = colors.dark3 })
  hl("TelescopeTitle", { fg = colors.green })

  -- native LSP completion menu (Pmenu)
  hl("Pmenu", { fg = colors.fg, bg = colors.bg_dark })
  hl("PmenuSel", { fg = colors.fg, bg = colors.bg_visual, bold = true })
  hl("PmenuKind", { fg = colors.dark_green, bg = colors.bg_dark })
  hl("PmenuKindSel", { fg = colors.green, bg = colors.bg_visual, bold = true })
  hl("PmenuExtra", { fg = colors.dark5, bg = colors.bg_dark })
  hl("PmenuExtraSel", { fg = colors.fg, bg = colors.bg_visual })
  hl("PmenuSbar", { bg = colors.bg_highlight })
  hl("PmenuThumb", { bg = colors.purple })

  -- floatterm border
  hl("FloatermBorder", { fg = colors.dark_cyan })
end

--- Apply agentic.nvim highlight overrides for agentic filetypes.
--- Runs once on the first matching FileType event.
local function apply_agentic_highlights()
  local colors = require("eldritch.colors").setup()
  local hl = function(name, val)
    vim.api.nvim_set_hl(0, name, val)
  end

  hl("AgenticDiffDelete", { bg = colors.diff.delete, fg = colors.red })
  hl("AgenticDiffAdd", { bg = nil, fg = colors.dark3 })
  hl("AgenticDiffDeleteWord", { bg = colors.red, fg = colors.bg_dark, bold = true })
  hl("AgenticDiffAddWord", { bg = colors.green, fg = colors.bg_dark, bold = true })
  hl("AgenticStatusPending", { bg = colors.magenta3, fg = colors.purple })
  hl("AgenticStatusCompleted", { bg = colors.dark_green, fg = colors.bg_dark })
  hl("AgenticStatusFailed", { bg = colors.red, fg = colors.bg_dark })
  hl("AgenticCodeBlockFence", { fg = colors.dark_cyan })
  hl("AgenticTitle", { bg = colors.dark_cyan, fg = colors.bg_dark, bold = true })
end

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
        -- Only highlights visible on the initial frame
        hl.WinSeparator = { fg = colors.bg_dark, bg = nil }
        hl.VertSplit = { fg = colors.fg_gutter, bg = nil }
        hl.LineNr = { fg = colors.dark5, bg = nil, bold = true }
        hl.CursorLineNr = { fg = colors.fg_dark, bg = nil, bold = true }
        hl.LspInlayHint = { fg = "#969696", bg = "NONE" }
        hl.SnacksIndent = { fg = colors.dark5, bg = nil }
        hl.SnacksIndentScope = { fg = colors.dark_cyan, bg = nil }
        hl.TabLineSel = { fg = colors.green, bg = colors.green }
        hl.WildMenu = { fg = colors.green, bg = colors.green }
      end,
    },
    init = function()
      vim.cmd.colorscheme("eldritch")

      -- Defer plugin-specific highlights until after the UI renders
      vim.api.nvim_create_autocmd("UIEnter", {
        once = true,
        callback = function()
          vim.schedule(apply_deferred_highlights)
        end,
      })

      -- Apply markdown highlights on first markdown-like buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "md", "Avante", "codecompanion", "AgenticChat" },
        once = true,
        callback = function()
          vim.schedule(apply_markdown_highlights)
        end,
      })

      -- Apply agentic highlights on first agentic buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "AgenticChat", "AgenticInput" },
        once = true,
        callback = function()
          vim.schedule(apply_agentic_highlights)
        end,
      })
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
