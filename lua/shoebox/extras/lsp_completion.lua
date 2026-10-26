local M = {}

local GROUP = "shoebox.lsp_completion"

local function completion_opts()
  return {
    autotrigger = false,
    convert = function(item)
      local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or "Text"
      return { abbr = item.label, kind = kind }
    end,
  }
end

-- shortcut: each LSP restart leaves the previous on_reload in place; drop dead
-- ids here. Remove the guard once Neovim no longer closes over the client id
-- (upstream master already stopped using on_reload).
local installed

local function invalid_client(err)
  return tostring(err):find("invalid client ID", 1, true) ~= nil
end

--- Neovim 0.12's completion on_reload closes over the first client id. Agentic
--- calls checktime after a tool write; if that client has stopped, enable()
--- asserts and the scheduled tool update dies.
local function install_guard()
  local current = vim.lsp.completion.enable
  if current == installed then
    return
  end

  local function enable_attached(bufnr, opts)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      if client:supports_method("textDocument/completion") then
        local ok, err = pcall(current, true, client.id, bufnr, opts)
        if not ok and not invalid_client(err) then
          error(err, 0)
        end
      end
    end
  end

  local function guarded(do_enable, client_id, bufnr, opts)
    bufnr = vim._resolve_bufnr(bufnr)
    if do_enable and vim.lsp.get_client_by_id(client_id) == nil then
      enable_attached(bufnr, opts)
      return
    end
    local ok, err = pcall(current, do_enable, client_id, bufnr, opts)
    if not ok and do_enable and invalid_client(err) then
      enable_attached(bufnr, opts)
      return
    end
    if not ok then
      error(err, 0)
    end
  end

  installed = guarded
  vim.lsp.completion.enable = guarded
end

---@param client_id integer
---@param bufnr integer
function M.enable_buffer(client_id, bufnr)
  local client = vim.lsp.get_client_by_id(client_id)
  if not client or not client:supports_method("textDocument/completion") then
    return
  end
  vim.lsp.completion.enable(true, client_id, bufnr, completion_opts())
end

function M.bootstrap_attached_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        M.enable_buffer(client.id, bufnr)
      end
    end
  end
end

--- Guard, LspAttach hook, and clients already attached before this runs (e.g. session restore).
function M.setup()
  install_guard()
  if vim.g.shoebox_lsp_completion_setup then
    return
  end
  vim.g.shoebox_lsp_completion_setup = true

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup(GROUP, { clear = true }),
    callback = function(args)
      M.enable_buffer(args.data.client_id, args.buf)
    end,
  })
  M.bootstrap_attached_buffers()
end

return M
