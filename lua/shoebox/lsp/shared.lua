local M = {}

---@param prefix string
---@param defs table[]
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

lsp_keys[#lsp_keys + 1] = {
  "<leader>f",
  function()
    vim.lsp.buf.format({ async = true })
  end,
  desc = "LSP: Format",
}

M.keys = vim.list_extend(lsp_keys, diag_keys)

M.capabilities = {
  workspace = {
    didChangeWatchedFiles = { dynamicRegistration = true },
  },
}

M.gopls_gomemlimit = "768MiB"

M.servers = {
  gopls = {
    cmd_env = { GOMEMLIMIT = M.gopls_gomemlimit },
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
        expandWorkspaceToModule = false,
        gofumpt = true,
        hints = {
          parameterNames = true,
        },
        templateExtensions = { "tmpl", "gotmpl", "gohtml", "gohtmltmpl" },
        standaloneTags = { "ignore" },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  ts_ls = {},
}

--- Neovim 0.11+ server definitions (no nvim-lspconfig plugin).
M.native = {
  gopls = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotexttmpl", "gohtmltmpl" },
    root_markers = { "go.mod", "go.work", ".git" },
  },
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".git" },
  },
  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
  },
}

function M.configure_diagnostics()
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
end

---@param server_names? string[] If set, only these servers are registered and enabled.
function M.apply_native(server_names)
  M.configure_diagnostics()
  vim.lsp.config("*", { capabilities = M.capabilities })

  local want = server_names
  local function include(name)
    return want == nil or vim.tbl_contains(want, name)
  end

  for name, body in pairs(M.servers) do
    if include(name) then
      local native = M.native[name] or {}
      vim.lsp.config(name, vim.tbl_deep_extend("force", native, body))
      vim.lsp.enable(name)
    end
  end

  if want == nil then
    require("shoebox.extras.lsp_resync").setup()
  end
end

return M
