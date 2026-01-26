local M = {}

-- Track multiple concurrent progress handles by request ID
M.fidget_progress_handles = {}

function M.start_fidget(adapter_name, request_id)
  local has_fidget, fidget = pcall(require, "fidget")
  if not has_fidget then
    return
  end

  -- If there's already a handle for this request ID, cancel it
  if request_id and M.fidget_progress_handles[request_id] then
    M.fidget_progress_handles[request_id].message = "Abort."
    M.fidget_progress_handles[request_id]:cancel()
    M.fidget_progress_handles[request_id] = nil
  end

  -- Build a better message with adapter name and request ID
  local message = "Thinking..."
  if adapter_name then
    message = string.format("%s - Thinking...", adapter_name)
  end
  if request_id then
    message = string.format("%s [#%s]", message, request_id)
  end

  local handle = fidget.progress.handle.create({
    title = "",
    message = message,
    lsp_client = { name = "CodeCompanion" },
  })

  -- Store the handle by request ID for concurrent tracking
  if request_id then
    M.fidget_progress_handles[request_id] = handle
  end
end

function M.stop_fidget(request_id)
  local has_fidget, _ = pcall(require, "fidget")
  if not has_fidget then
    return
  end

  -- Find and finish the specific request's progress handle
  if request_id and M.fidget_progress_handles[request_id] then
    M.fidget_progress_handles[request_id].message = "Done."
    M.fidget_progress_handles[request_id]:finish()
    M.fidget_progress_handles[request_id] = nil
  end
end

function M.setup_fidget()
  local has_fidget, _ = pcall(require, "fidget")
  if has_fidget then
    -- New AU group:
    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

    -- Attach:
    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = "CodeCompanionRequest*",
      group = group,
      callback = function(request)
        local adapter = request.data.adapter
        local id = request.data.id
        if request.match == "CodeCompanionRequestStarted" then
          -- Use formatted_name if available, otherwise fall back to name
          local adapter_name = adapter and (adapter.formatted_name or adapter.name) or nil
          M.start_fidget(adapter_name, id)
        elseif request.match == "CodeCompanionRequestFinished" then
          M.stop_fidget(id)
        end
      end,
    })
  end
end

return M
