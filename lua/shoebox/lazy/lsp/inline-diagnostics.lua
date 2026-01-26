return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  setup = function()
    vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
  end,
  opts = {
    transparent_bg = true,
    show_source = {
      enabled = true,
    },
    throttle = 10000,
    severity = {
      vim.diagnostic.severity.ERROR,
      vim.diagnostic.severity.WARN,
      vim.diagnostic.severity.INFO,
      -- vim.diagnostic.severity.HINT,
    },
  },
}
