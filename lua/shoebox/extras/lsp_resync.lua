local M = {}

---@param path string
---@return boolean
function M.go_workspace_path(path)
  if path == "" then
    return false
  end
  local base = vim.fn.fnamemodify(path, ":t")
  if base == "go.mod" or base == "go.sum" or base == "go.work" or base == "go.work.sum" then
    return true
  end
  return vim.endswith(path, ".go")
end

--- Stop and start an LSP server (reattaches open buffers on the client).
---@param server_name string
function M.restart_server(server_name)
  if not vim.lsp.config[server_name] then
    return
  end
  if vim.lsp.is_enabled(server_name) then
    vim.lsp.enable(server_name, false)
  end
  vim.lsp.enable(server_name)
end

function M.restart_gopls()
  vim.schedule(function()
    M.restart_server("gopls")
  end)
end

--- Re-open the buffer document for each attached LSP client (didClose + didOpen).
---@param bufnr integer
function M.resync_buffer(bufnr)
  bufnr = vim._resolve_bufnr(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
    return
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return
  end

  local client_ids = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if vim.lsp.buf_is_attached(bufnr, client.id) then
      client_ids[#client_ids + 1] = client.id
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
  end
  for _, client_id in ipairs(client_ids) do
    if vim.lsp.get_client_by_id(client_id) then
      vim.lsp.buf_attach_client(bufnr, client_id)
    end
  end
end

--- Drop LSP state for a buffer whose file no longer exists on disk.
---@param bufnr integer
function M.close_buffer_document(bufnr)
  bufnr = vim._resolve_bufnr(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if vim.lsp.buf_is_attached(bufnr, client.id) then
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
  end
  vim.diagnostic.reset(nil, bufnr)
end

local function in_go_module()
  return vim.fs.find("go.mod", { upward = true, path = vim.fn.getcwd() })[1] ~= nil
end

function M.setup()
  require("shoebox.extras.lsp_completion").setup()

  if vim.g.shoebox_lsp_resync_setup then
    return
  end
  vim.g.shoebox_lsp_resync_setup = true

  local group = vim.api.nvim_create_augroup("shoebox.lsp_resync", { clear = true })

  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = group,
    callback = function(ev)
      local bufnr = ev.buf
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name == "" or vim.bo[bufnr].buftype ~= "" then
        return
      end
      if vim.v.fcs_reason == "delete" or vim.fn.filereadable(name) == 0 then
        M.close_buffer_document(bufnr)
        if M.go_workspace_path(name) then
          M.restart_gopls()
        end
        return
      end
      -- No full gopls restart here: checktime (e.g. agentic after write) races completion on_reload.
      M.resync_buffer(bufnr)
    end,
  })

  vim.api.nvim_create_autocmd("DirChanged", {
    group = group,
    callback = function()
      if in_go_module() then
        M.restart_gopls()
      end
    end,
  })

  vim.api.nvim_create_user_command("GoplsRestart", function()
    M.restart_gopls()
  end, { desc = "Restart gopls (full workspace reload)" })
end

return M
