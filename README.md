# 🧰 Shoebox

Personal Neovim configuration built on [lazy.nvim](https://github.com/folke/lazy.nvim).

## Requirements

- Neovim ≥ 0.10
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (for icons)
- Optional: `tmux`, `yazi`, `ripgrep`, `fd`

## Structure

```
~/.config/nvim/
├── init.lua                        # Entry point
├── lua/shoebox/
│   ├── core/                       # Options, autocmds, filetypes, abbreviations
│   ├── mapping/                    # Global keymaps
│   ├── lazy_init.lua               # lazy.nvim bootstrap and plugin spec imports
│   ├── lazy/
│   │   ├── completion/             # Native LSP completion
│   │   ├── lang/                   # Language support (treesitter, conform, lint, go, markdown)
│   │   ├── llm/                    # AI plugins (agentic.nvim, codecompanion, speckit)
│   │   ├── lsp/                    # LSP config and inline diagnostics
│   │   ├── tools/                  # Session management, file manager, terminal
│   │   ├── ui/                     # Theme, statusline, bufferline, gitsigns, fidget
│   │   └── util/                   # Telescope, neotest, obsidian, snacks, git-worktree
│   ├── llm/                        # LLM prompt templates and roles
│   └── extras/                     # Custom extensions (fidget integration)
└── queries/                        # Custom tree-sitter queries (gherkin)
```

## Plugin Highlights

| Category | Plugins |
|----------|---------|
| Theme | [eldritch.nvim](https://github.com/eldritch-theme/eldritch.nvim) |
| Completion | Native LSP completion (`vim.lsp.completion`) |
| LSP | [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig), inline-diagnostics |
| Treesitter | [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) |
| AI | [agentic.nvim](https://github.com/carlos-algms/agentic.nvim), [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) |
| File manager | [yazi.nvim](https://github.com/mikavilpas/yazi.nvim) |
| Terminal | [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) |
| Git | [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [octo.nvim](https://github.com/pwntester/octo.nvim) |
| Statusline | [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) |
| Notifications | [fidget.nvim](https://github.com/j-hui/fidget.nvim) |
| Fuzzy finder | [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) |
| Testing | [neotest](https://github.com/nvim-neotest/neotest) |
| Sessions | [auto-session](https://github.com/rmagatti/auto-session) |
| Notes | [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) |

## Install

```bash
git clone https://github.com/<user>/nvim ~/.config/nvim
nvim
```

Plugins will be installed automatically on first launch via lazy.nvim.
