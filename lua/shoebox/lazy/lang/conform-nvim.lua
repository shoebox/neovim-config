return {
  {
    "stevearc/conform.nvim",
    config = function()
      local conform = require("conform")
      conform.formatters.yamlfmt = {
        prepend_args = {
          "-formatter",
          "retain_line_breaks=true",
          "include_document_start=true",
        },
      }

      conform.setup({
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
        notify_on_error = true,
        notify_no_formatters = false,
        formatters_by_ft = {
          ["go"] = {
            "gofumpt",
            "golangci-lint",
            "golines",
            "gopls",
            "goimports-reviser",
          },
          ["lua"] = { "stylua" },
          ["nix"] = { "alejandra", "nixfmt", "nixpkgs_fmt" },
          -- ["tf"] = {
          --   "terraform_fmt",
          --   formatters = {
          --     dprint = {
          --       condition = function(_, ctx)
          --         return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          --       end,
          --     },
          --   },
          -- },
          ["js"] = { "prettier" },
          ["json"] = { "gojq" },
          ["toml"] = { "taplo" },
          ["yaml"] = { "yamlfmt" },
        },
      })
    end,
    event = "BufReadPost",
    priority = 1000,
  },
}
