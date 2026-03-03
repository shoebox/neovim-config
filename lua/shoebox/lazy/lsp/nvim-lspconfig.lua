return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    keys = {
      { "gD", vim.lsp.buf.declaration, desc = "LSP: Go to declaration" },
      { "gd", vim.lsp.buf.definition, desc = "LSP: Go to definition" },
      { "K", vim.lsp.buf.hover, desc = "LSP: Hover" },
      { "gi", vim.lsp.buf.implementation, desc = "LSP: Go to implementation" },
      { "<C-k>", vim.lsp.buf.signature_help, desc = "LSP: Signature help" },
      { "<leader>D", vim.lsp.buf.type_definition, desc = "LSP: Type definition" },
      { "<leader>rn", vim.lsp.buf.rename, desc = "LSP: Rename" },
      { "gr", vim.lsp.buf.references, desc = "LSP: References" },
      {
        "<leader>f",
        function()
          vim.lsp.buf.format({ async = true })
        end,
        desc = "LSP: Format",
      },
      -- workspace
      { "<space>wa", vim.lsp.buf.add_workspace_folder, desc = "LSP: Add workspace folder" },
      { "<space>wr", vim.lsp.buf.remove_workspace_folder, desc = "LSP: Remove workspace folder" },
      -- diagnostics
      { "<leader>dl", vim.diagnostic.open_float, desc = "LSP: Open diagnostic float" },
      { "<leader>dn", vim.diagnostic.goto_next, desc = "LSP: Next diagnostic" },
      { "<leader>dp", vim.diagnostic.goto_prev, desc = "LSP: Previous diagnostic" },
      { "<leader>dh", vim.diagnostic.hide, desc = "LSP: Hide diagnostics" },
      { "<leader>ds", vim.diagnostic.show, desc = "LSP: Show diagnostics" },
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
