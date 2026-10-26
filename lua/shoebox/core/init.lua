require("shoebox.core.abbrev")
require("shoebox.core.autocmd")
require("shoebox.core.filetype")
require("shoebox.core.global")
require("shoebox.core.options")

require("shoebox.extras.tmux_worktree").setup()
require("shoebox.extras.herd").setup()
-- Before plugins attach LSP. checktime (agentic tool writes) reloads buffers
-- through vim.lsp.completion's on_reload, which asserts on a stopped client.
require("shoebox.extras.lsp_completion").setup()
