local M = {}
local installed = false
local provider_labels = {
  ["copilot-acp"] = " Copilot",
  ["cursor-acp"] = "󰝮 Cursor",
}

local function dismiss(item)
  if item.handle then
    item.handle:cancel()
    vim.schedule(function()
      require("fidget.notification").remove(item.handle.lsp_client.name, item.handle.token)
    end)
  end
  item.terminal = true
end

local function dismiss_notifications(writer)
  for _, item in pairs(writer._command_notifications) do
    dismiss(item)
  end
  writer._command_notifications = {}
end

local function command_notify(writer, widget, tool_call_id)
  if writer._replaying_activity then
    return
  end
  local block = writer.tool_call_blocks[tool_call_id]
  if not block then
    return
  end
  local entries = writer._command_notifications
  local item = entries[tool_call_id]
  local status = block.status or "pending"
  local terminal = status == "completed" or status == "failed"
  if not item then
    item = { ready = false, terminal = terminal, started_at = vim.uv.hrtime() }
    entries[tool_call_id] = item
    if not terminal then
      vim.defer_fn(function()
        if writer._command_notifications ~= entries or item.terminal then
          return
        end
        item.ready = true
        command_notify(writer, widget, tool_call_id)
      end, 3000)
    end
  end
  if not item.ready then
    item.terminal = terminal
    return
  end
  if item.terminal then
    return
  end
  local message = vim.trim(block.argument or block.kind or "tool")
  local elapsed = math.floor((vim.uv.hrtime() - item.started_at) / 1e9 + 0.5)
  local title = string.format("%s (%ds)", block.kind or "tool", elapsed)
  if not item.handle then
    local progress = require("fidget.progress")
    local group = "Agentic #" .. (widget.session_key or widget.buf_nrs.chat)
    local config = progress.display.make_config(group)
    local provider = writer._provider_name
    if provider then
      config.name = (provider_labels[provider] or provider) .. " · " .. group
    end
    require("fidget.notification").set_config(group, config, true)
    item.handle = progress.handle.create({
      title = title,
      message = message,
      lsp_client = { name = group },
    })
    local function tick()
      if writer._command_notifications ~= entries or item.terminal then
        return
      end
      command_notify(writer, widget, tool_call_id)
      if not item.terminal then
        vim.defer_fn(tick, 1000)
      end
    end
    vim.defer_fn(tick, 1000)
  else
    item.handle:report({ title = title, message = message })
  end
  item.terminal = terminal
  if terminal then
    item.handle:finish()
    if status == "failed" then
      require("fidget.notification").notify(message, "DiagnosticError", {
        group = item.handle.lsp_client.name,
        key = item.handle.token,
        annote = string.format("Failed (%ds)", elapsed),
        ttl = 5,
        data = true,
        update_only = true,
      })
    end
  end
end

local function close(widget)
  local win = widget._commands_win
  widget._commands_win = nil
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

local function show(widget)
  local chat = widget.win_nrs.chat
  if not widget._commands_enabled or not widget:get_visible_tab_id() then
    return
  end
  if widget._commands_win and vim.api.nvim_win_is_valid(widget._commands_win) then
    return
  end
  local height = math.max(1, math.floor(vim.api.nvim_win_get_height(chat) / 3))
  local win = vim.api.nvim_open_win(widget.buf_nrs.commands, false, {
    split = "below",
    win = chat,
    height = height,
    noautocmd = true,
  })
  widget._commands_win = win
  vim.w[win].agentic_bufnr = widget.buf_nrs.commands
  for name, value in pairs({
    number = false,
    relativenumber = false,
    wrap = true,
    linebreak = true,
    winfixheight = true,
    signcolumn = "no",
    foldcolumn = "0",
    foldenable = false,
    colorcolumn = "",
    statuscolumn = require("agentic.ui.tool_block_border").STATUSCOLUMN_EXPR,
    winbar = "Commands / Activity  |  <localLeader>x: toggle",
  }) do
    vim.wo[win][0][name] = value
  end
  vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(widget.buf_nrs.commands), 0 })
  widget:render_header("commands")
end

function M.toggle(widget)
  widget._commands_enabled = not widget._commands_enabled
  if widget._commands_enabled then
    show(widget)
  else
    close(widget)
  end
end

function M.setup()
  if installed then
    return
  end
  installed = true
  local ChatWidget = require("agentic.ui.chat_widget")
  local MessageWriter = require("agentic.ui.message_writer")
  local PermissionManager = require("agentic.ui.permission_manager")
  local Registry = require("agentic.ui.widget_registry")

  local create_bufs = ChatWidget._create_buf_nrs
  ChatWidget._create_buf_nrs = function(self)
    local bufs = create_bufs(self)
    bufs.commands = self:_create_new_buf({ filetype = "AgenticChat" })
    self.headers.commands = {
      title = "Commands / Activity",
      suffix = "<localLeader>x: toggle",
    }
    self._commands_enabled = false
    for _, buf in pairs(bufs) do
      vim.keymap.set({ "n", "i" }, "<localLeader>x", function()
        M.toggle(self)
      end, { buffer = buf, desc = "Agentic: Toggle commands pane" })
    end
    require("agentic.ui.chat_navigation").setup_keymaps(bufs.commands)
    return bufs
  end

  local new_widget = ChatWidget.new
  ChatWidget.new = function(self, ...)
    local widget = new_widget(self, ...)
    vim.api.nvim_create_autocmd("WinClosed", {
      group = widget._winclosed_augroup,
      callback = function(ev)
        if tonumber(ev.match) == widget._commands_win then
          widget._commands_win = nil
          widget._commands_enabled = false
        end
      end,
    })
    return widget
  end

  local show_widget = ChatWidget.show
  ChatWidget.show = function(self, ...)
    show_widget(self, ...)
    show(self)
  end
  for _, method in ipairs({ "hide", "destroy" }) do
    local original = ChatWidget[method]
    ChatWidget[method] = function(self, ...)
      close(self)
      if method == "destroy" and self._commands_writer then
        dismiss_notifications(self._commands_writer)
      end
      return original(self, ...)
    end
  end

  -- Keep the primary writer on activity so tool tracking, diffs and permissions
  -- continue to use upstream's buffer/extmarks. Only conversation writes move.
  local new_writer = MessageWriter.new
  local replay = MessageWriter.replay_history_messages
  MessageWriter.new = function(self, buf)
    local widget = Registry.get(buf)
    if not widget or buf ~= widget.buf_nrs.chat then
      return new_writer(self, buf)
    end
    local conversation = new_writer(self, buf)
    local writer = new_writer(self, widget.buf_nrs.commands)
    writer._conversation = conversation
    writer._command_notifications = {}
    widget._commands_writer = writer
    for _, method in ipairs({ "write_tool_call_block", "update_tool_call_block" }) do
      writer[method] = function(_, block)
        MessageWriter[method](writer, block)
        command_notify(writer, widget, block.tool_call_id)
      end
    end
    for _, method in ipairs({
      "write_message",
      "write_message_chunk",
      "write_structural_message",
      "write_restoring_message",
      "write_finish_message",
    }) do
      writer[method] = function(_, ...)
        if method == "write_finish_message" then
          for _, item in pairs(writer._command_notifications) do
            if not item.terminal then
              dismiss(item)
            end
          end
        end
        conversation._provider_name = writer._provider_name
        return conversation[method](conversation, ...)
      end
    end
    for _, method in ipairs({ "set_provider_name", "reset_sender_tracking", "destroy" }) do
      writer[method] = function(_, ...)
        if method == "destroy" then
          dismiss_notifications(writer)
        end
        MessageWriter[method](writer, ...)
        return conversation[method](conversation, ...)
      end
    end
    writer.replay_history_messages = function(_, messages)
      writer._replaying_activity = true
      local ok, err = pcall(function()
        for _, message in ipairs(messages) do
          conversation._provider_name = writer._provider_name
          replay(message.type == "tool_call" and writer or conversation, { message })
        end
      end)
      writer._replaying_activity = false
      if not ok then
        error(err)
      end
    end
    return writer
  end

  local find_win = PermissionManager._find_visible_chat_winid
  PermissionManager._find_visible_chat_winid = function(self)
    if not self.message_writer._conversation then
      return find_win(self)
    end
    local widget = Registry.get(self.message_writer.bufnr)
    local win = widget and widget._commands_win
    if win and vim.api.nvim_win_is_valid(win) and widget:get_visible_tab_id() then
      return win
    end
  end
  local add_request = PermissionManager.add_request
  PermissionManager.add_request = function(self, ...)
    if self.message_writer._conversation then
      local widget = Registry.get(self.message_writer.bufnr)
      if widget and widget:get_visible_tab_id() then
        widget._commands_enabled = true
        show(widget)
      end
    end
    return add_request(self, ...)
  end
end

return M
