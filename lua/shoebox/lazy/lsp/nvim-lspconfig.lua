--- Helper: build lazy.nvim key entries from a compact {lhs, fn, desc} list.
---@param prefix string  Description prefix, e.g. "LSP" or "Diagnostic"
---@param defs   table[] Each entry: { [1]=lhs, [2]=function, [3]=desc }
---@return table[]
local function build_keys(prefix, defs)
  local keys = {}
  for _, def in ipairs(defs) do
    keys[#keys + 1] = { def[1], def[2], desc = prefix .. ": " .. def[3] }
  end
  return keys
end

-- stylua: ignore start
local lsp_keys = build_keys("LSP", {
  { "gD",         vim.lsp.buf.declaration,              "Go to declaration" },
  { "gd",         vim.lsp.buf.definition,               "Go to definition" },
  { "K",          vim.lsp.buf.hover,                    "Hover" },
  { "gi",         vim.lsp.buf.implementation,           "Go to implementation" },
  { "<C-k>",      vim.lsp.buf.signature_help,           "Signature help" },
  { "<leader>D",  vim.lsp.buf.type_definition,          "Type definition" },
  { "<leader>rn", vim.lsp.buf.rename,                   "Rename" },
  { "gr",         vim.lsp.buf.references,               "References" },
  { "<space>wa",  vim.lsp.buf.add_workspace_folder,     "Add workspace folder" },
  { "<space>wr",  vim.lsp.buf.remove_workspace_folder,  "Remove workspace folder" },
})

local diag_keys = build_keys("LSP", {
  { "<leader>dl", vim.diagnostic.open_float, "Open diagnostic float" },
  { "<leader>dn", vim.diagnostic.goto_next,  "Next diagnostic" },
  { "<leader>dp", vim.diagnostic.goto_prev,  "Previous diagnostic" },
  { "<leader>dh", vim.diagnostic.hide,       "Hide diagnostics" },
  { "<leader>ds", vim.diagnostic.show,       "Show diagnostics" },
})
-- stylua: ignore end

-- Format needs a custom call, so add it separately.
lsp_keys[#lsp_keys + 1] = {
  "<leader>f",
  function()
    vim.lsp.buf.format({ async = true })
  end,
  desc = "LSP: Format",
}

local all_keys = vim.list_extend(lsp_keys, diag_keys)

---------------------------------------------------------------------------
-- Server configurations — one table per server keeps each concern isolated
-- and makes it easy to add / remove servers without touching the rest.
---------------------------------------------------------------------------
local servers = {}

-- Soft heap cap via Go runtime (GOMEMLIMIT); not all gopls builds expose memoryLimit in settings.
local gopls_gomemlimit = "768MiB"

servers.gopls = {
  cmd_env = { GOMEMLIMIT = gopls_gomemlimit },
  settings = {
    gopls = {
      analyses = {
        shadow = false,
        unusedwrite = true,
        unusedvariable = true,
      },
      buildFlags = { "-tags=integrationtest,testing,test,debug,e2e" },
      codelenses = {
        gc_details = false,
        generate = false,
        regenerate = false,
        tidy = false,
        vulncheck = false,
      },
      directoryFilters = {
        "-**/.git",
        "-**/.cache",
        "-**/bin",
        "-**/dist",
        "-**/node_modules",
        "-**/testdata",
        "-**/vendor",
      },
      -- Narrow workspace packages (see gopls expandWorkspaceToModule); module still via go.mod.
      expandWorkspaceToModule = false,
      gofumpt = true,
      hints = {
        parameterNames = true,
      },
      templateExtensions = { "tmpl", "gotmpl", "gohtml", "gohtmltmpl" },
      standaloneTags = { "ignore" },
    },
  },
}

servers.lua_ls = {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

servers.ts_ls = {}

---------------------------------------------------------------------------
-- BACKUP: re-enable this spec and disable native.lua to roll back to nvim-lspconfig.
return {
  {
    "neovim/nvim-lspconfig",
    enabled = false,
    event = "BufReadPre",
    keys = all_keys,
    opts = {
      capabilities = {
        workspace = {
          didChangeWatchedFiles = { dynamicRegistration = true },
        },
      },
      servers = servers,
    },
    config = function(_, opts)
      for server_name, server_config in pairs(opts.servers or {}) do
        local config = vim.tbl_deep_extend("force", {
          capabilities = opts.capabilities,
        }, server_config)
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end
      require("shoebox.extras.lsp_resync").setup()
    end,
    init = function()
      vim.diagnostic.config({
        update_in_insert = false,
        virtual_text = { source = "always" },
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
