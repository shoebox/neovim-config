local vim = vim

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

local function keymaps(ev)
  local opts = { buffer = ev.buf }

  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

  -- formatting
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)

  -- code actions
  -- vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

  -- workspace
  vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)

  -- diagnostics
  vim.keymap.set("n", "<leader>dl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  vim.keymap.set("n", "<leader>dn", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  vim.keymap.set("n", "<leader>dp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  vim.keymap.set("n", "<leader>dh", "<cmd>lua vim.diagnostic.hide()<CR>", opts)
  vim.keymap.set("n", "<leader>ds", "<cmd>lua vim.diagnostic.show()<CR>", opts)
end

local function createAuGroup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
      keymaps(ev)
    end,
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {},
    event = "BufReadPre",
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
        gopls = {},
        lua_ls = {},
      },
    },
    config = function()
      vim.lsp.enable("lua_ls", {
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
      })

      vim.lsp.enable("gopls", {
        settings = {
          gopls = {
            analyses = {
              shadow = true,
              unusedwrite = true,
              unusedvariable = true,
            },
            -- Enhanced build flags configuration for better build tag support
            buildFlags = { "-tags=integration,test,debug" },
            -- Alternative: use env to set GOFLAGS
            env = {
              GOFLAGS = "-tags=integration,test,debug",
            },
            -- Ensure gopls processes all files regardless of build tags
            directoryFilters = { "-**/node_modules", "-**/vendor" },
            -- Include test files and build-tagged files
            expandWorkspaceToModule = true,
            experimentalWorkspaceModule = true,
            gofumpt = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = false,
              functionTypeParameters = false,
              parameterNames = false,
              rangeVariableTypes = false,
            },
            staticcheck = true,
            -- Ensure all Go files are analyzed
            templateExtensions = { "tmpl", "gotmpl", "gohtml", "gohtmltmpl" },
            -- Better handling of build constraints
            standaloneTags = { "ignore" },
          },
        },
      })
    end,
    init = function()
      createAuGroup()
    end,
  },
}
