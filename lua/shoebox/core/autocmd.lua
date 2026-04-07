local vim = vim

-- Autocmd group for auto-save functionality
local focus_group = vim.api.nvim_create_augroup("focus_group", {})

-- Buffer types to ignore when auto-saving
local ignore_buftype = {
  "acwrite",
  "filesystem",
  "nofile",
  "nowrite",
  "prompt",
  "terminal",
}

-- User command to close all buffers that are not within the current workspace directory
vim.api.nvim_create_user_command("CloseBuffersNotInWorkspace", function()
  local workspace = vim.fs.normalize(vim.fn.getcwd())
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if not vim.api.nvim_buf_is_loaded(buf) then
      goto continue
    end

    local filepath = vim.api.nvim_buf_get_name(buf)
    if filepath == "" or vim.startswith(vim.fs.normalize(filepath), workspace) then
      goto continue
    end

    -- Close the buffer
    local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = true })
    if ok then
      vim.notify(("Closed buffer %s"):format(filepath))
    else
      vim.notify(("Failed to close buffer %s: %s"):format(filepath, err), vim.log.levels.WARN)
    end
    ::continue::
  end
end, { desc = "Close all buffers not in workspace" })

-- User command to close all buffers except the current one
vim.api.nvim_create_user_command("CloseBuffersExpectCurrent", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = false })
    end
  end
end, { desc = "Close all buffer but current one" })

-- User command to wipe out all buffers that are not currently displayed in any window
vim.api.nvim_create_user_command("WipeWindowlessBufs", function()
  local bufinfos = vim.fn.getbufinfo({ buflisted = true })
  for _, bufinfo in ipairs(bufinfos) do
    if bufinfo.changed == 0 and (not bufinfo.windows or #bufinfo.windows == 0) then
      vim.notify(("Deleting buffer %d : %s"):format(bufinfo.bufnr, bufinfo.name))
      pcall(vim.api.nvim_buf_delete, bufinfo.bufnr, { force = false, unload = false })
    end
  end
end, { desc = "Wipeout all buffers not shown in a window" })

-- Autocmd to automatically save modified buffers when leaving them or losing focus
-- Skips readonly, non-modifiable, special buffer types, and unnamed buffers
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  group = focus_group,
  pattern = "*",
  callback = function(args)
    if vim.bo[args.buf].readonly or not vim.bo[args.buf].modifiable then
      return
    end

    local buftype = vim.bo[args.buf].buftype
    if vim.tbl_contains(ignore_buftype, buftype) then
      return
    end

    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname == "" then
      return
    end

    if vim.bo[args.buf].modified then
      local ok, err = pcall(vim.cmd.w, { mods = { silent = true } })
      if not ok then
        vim.notify(("Failed to save buffer: %s"):format(err), vim.log.levels.ERROR)
      end
    end
  end,
})

-- Show relative line number when in command mode and absolute line number in edit mode
-- local function relativeln(target)
--   vim.o.number = true
--
--   if target == "number" then
--     vim.o.number = true
--     vim.o.relativenumber = false
--   else
--     vim.o.number = true
--     vim.o.relativenumber = true
--   end
-- end

-- local _group = vim.api.nvim_create_augroup("LineNumber", { clear = true })
-- local autocmd_config = {
--   ["InsertEnter"] = "number",
--   ["InsertLeave"] = "relativenumber",
--   ["FocusGained"] = "relativenumber",
--   ["FocusLost"] = "number",
--   ["CursorMoved"] = "relativenumber",
-- }
--
-- for event, argument in pairs(autocmd_config) do
--   vim.api.nvim_create_autocmd(event, {
--     pattern = "*",
--     callback = function()
--       relativeln(argument)
--     end,
--     once = true,
--     group = _group,
--   })
-- end

-- Autocmd group for checking if files have been modified outside of Neovim
local checktime_group = vim.api.nvim_create_augroup("checktime_group", { clear = true })

-- Autocmd to check if files have been modified externally and reload them if needed
-- Runs on buffer enter, cursor hold events, and when Neovim gains focus
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  group = checktime_group,
  command = "if mode() != 'c' | checktime | endif",
  pattern = "*",
})
