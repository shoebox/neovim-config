return {
  "j-hui/fidget.nvim",
  lazy = false,
  opts = {
    notification = {
      override_vim_notify = true,
      redirect = false,
      window = {
        winblend = 0,
        normal_hl = "FidgetNormal",
        max_width = 0.30,
      },
      view = { reflow = "hyphenate" },
    },
    progress = {
      display = {
        done_ttl = 2,
        progress_style = "DiagnosticInfo",
        done_style = "DiagnosticOk",
        group_style = "FidgetTitle",
        overrides = {
          ["nvim-lint"] = {
            name = "nvim-lint",
          },
        },
      },
    },
  },
}
