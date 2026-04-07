return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  setup = function()
    vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
  end,
  opts = {
    multilines = {
      enabled = true,
      trim_whitespaces = true,
    },
    options = {
      enable_on_insert = false,
    },
    show_source = {
      enabled = true,
    },
    throttle = 100,
    transparent_bg = true,
  },
}
