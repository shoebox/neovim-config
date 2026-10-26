--- Native LSP via vim.lsp.config / vim.lsp.enable (Neovim 0.11+).
--- `dir` is required: lazy.nvim rejects specs with neither a plugin id, url, nor dir.
local shared = require("shoebox.lsp.shared")

return {
  {
    name = "shoebox-lsp",
    dir = vim.fn.stdpath("config") .. "/lua/shoebox/lsp",
    event = "BufReadPre",
    keys = shared.keys,
    config = function()
      shared.apply_native()
    end,
  },
}
