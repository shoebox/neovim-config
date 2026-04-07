return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    keys = {
      { "gD", function() vim.lsp.buf.declaration() end, desc = "LSP: Go to declaration" },
      { "gd", function() vim.lsp.buf.definition() end, desc = "LSP: Go to definition" },
      { "K", function() vim.lsp.buf.hover() end, desc = "LSP: Hover" },
      { "gi", function() vim.lsp.buf.implementation() end, desc = "LSP: Go to implementation" },
      { "<C-k>", function() vim.lsp.buf.signature_help() end, desc = "LSP: Signature help" },
      { "<leader>D", function() vim.lsp.buf.type_definition() end, desc = "LSP: Type definition" },
      { "<leader>rn", function() vim.lsp.buf.rename() end, desc = "LSP: Rename" },
      { "gr", function() vim.lsp.buf.references() end, desc = "LSP: References" },
      {
        "<leader>f",
        function()
          vim.lsp.buf.format({ async = true })
        end,
        desc = "LSP: Format",
      },
      -- workspace
      { "<space>wa", function() vim.lsp.buf.add_workspace_folder() end, desc = "LSP: Add workspace folder" },
      { "<space>wr", function() vim.lsp.buf.remove_workspace_folder() end, desc = "LSP: Remove workspace folder" },
      -- diagnostics
      { "<leader>dl", function() vim.diagnostic.open_float() end, desc = "LSP: Open diagnostic float" },
      { "<leader>dn", function() vim.diagnostic.goto_next() end, desc = "LSP: Next diagnostic" },
      { "<leader>dp", function() vim.diagnostic.goto_prev() end, desc = "LSP: Previous diagnostic" },
      { "<leader>dh", function() vim.diagnostic.hide() end, desc = "LSP: Hide diagnostics" },
      { "<leader>ds", function() vim.diagnostic.show() end, desc = "LSP: Show diagnostics" },
    },
    opts = {
      diagnostics = {
        virtual_text = { prefix = "icons" },
      },
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = false,
          },
        },
      },
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                shadow = true,
                unusedwrite = true,
                unusedvariable = true,
              },
              buildFlags = { "-tags=integration,test,debug,e2e" },
              directoryFilters = { "-**/node_modules", "-**/vendor" },
              expandWorkspaceToModule = true,
              experimentalWorkspaceModule = true,
              gofumpt = true,
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = false,
                parameterNames = true,
                rangeVariableTypes = false,
              },
              staticcheck = true,
              templateExtensions = { "tmpl", "gotmpl", "gohtml", "gohtmltmpl" },
              standaloneTags = { "ignore" },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
        ts_ls = {},
      },
    },
    config = function(_, opts)
      -- Enable each LSP server with its configuration
      for server_name, server_config in pairs(opts.servers or {}) do
        local config = vim.tbl_deep_extend("force", {
          capabilities = opts.capabilities,
        }, server_config)

        vim.lsp.enable(server_name, config)
      end
    end,
    init = function()
      vim.diagnostic.config({
        update_in_insert = false,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
    end,
  },
}
