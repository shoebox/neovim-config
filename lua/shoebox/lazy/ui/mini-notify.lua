-- Module-local shared state (replaces _G globals)
local state = {
  header_lines = {}, -- tracks which buffer lines (0-indexed) are group headers
  current_line = 0,
}

--- Extract the group name from a notification's data table.
local function notification_group(notif)
  local data = notif.data or {}
  return data.client_name or data.source or ""
end

--- Sort notifications by group, then by update timestamp.
--- Marks the first notification of each group as a header.
local function sort_notifications(notif_arr)
  table.sort(notif_arr, function(a, b)
    local ga, gb = notification_group(a), notification_group(b)
    if ga ~= gb then return ga < gb end
    return a.ts_update < b.ts_update
  end)

  state.header_lines = {}
  state.current_line = 0
  local last_group = nil
  for _, notif in ipairs(notif_arr) do
    local g = notification_group(notif)
    notif.data = notif.data or {}
    notif.data._group_header = (g ~= "" and g ~= last_group)
    last_group = g
  end
  return notif_arr
end

--- Format a single notification, inserting group headers when needed.
local function format_notification(notif)
  local data = notif.data or {}
  local group = data.client_name or data.source or ""
  local msg = notif.msg

  if group ~= "" and data._group_header then
    local prefix = ""
    if state.current_line > 0 then
      prefix = "\n"
      state.current_line = state.current_line + 1
    end
    state.header_lines[state.current_line] = true
    state.current_line = state.current_line + 1 + #vim.split(msg, "\n", { plain = true })
    return prefix .. group .. "\n" .. msg
  end

  state.current_line = state.current_line + #vim.split(msg, "\n", { plain = true })
  return msg
end

--- Right-align a single buffer line using an inline virtual-text extmark.
local function right_align_line(buf, ns, row, line, win_width)
  local pad = win_width - vim.fn.strdisplaywidth(line)
  if pad > 0 then
    vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
      virt_text = { { string.rep(" ", pad), "MiniNotifyNormal" } },
      virt_text_pos = "inline",
    })
  end
end

--- Apply bold highlight to a group-header line.
local function highlight_header(buf, ns, row, line)
  vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
    end_col = #line,
    hl_group = "MiniNotifyGroupHeader",
  })
end

local BOLD_PATTERNS = { " attached", " detached", " %- Thinking", " %- Done" }

--- Bold the client/source name prefix in lifecycle messages.
local function highlight_client_name(buf, ns, row, line)
  for _, pattern in ipairs(BOLD_PATTERNS) do
    local pos = line:find(pattern)
    if pos then
      vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
        end_col = pos - 1,
        hl_group = "MiniNotifyGroupHeader",
      })
      return
    end
  end
end

--- Decorate all lines in a single mininotify buffer.
local function decorate_buffer(buf, win_width, ns)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  for i, line in ipairs(lines) do
    local row = i - 1
    right_align_line(buf, ns, row, line, win_width)
    if state.header_lines[row] then
      highlight_header(buf, ns, row, line)
    end
    highlight_client_name(buf, ns, row, line)
  end
end

--- mini.notify calls window.config after writing content but before opening/redrawing.
local function window_position(buf)
  local width = 1
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  local share = require("mini.notify").config.window.max_width_share
  local max_width = math.max(1, math.floor(vim.o.columns * share))
  width = math.min(width, max_width, vim.o.columns)
  local ns = vim.api.nvim_create_namespace("mini_notify_custom")
  decorate_buffer(buf, width, ns)
  local has_statusline = vim.o.laststatus > 0
  local pad = vim.o.cmdheight + (has_statusline and 1 or 0)
  return {
    anchor = "SE",
    col = vim.o.columns - 2,
    row = vim.o.lines - pad - 1,
    border = "none",
    width = width,
  }
end


--- Override vim.notify with per-level durations and highlight groups.
--- ERROR-level notifications are also logged to :messages so they persist.
local function install_notify_levels(notify)
  local mini_notify = notify.make_notify({
    DEBUG = { duration = 0, hl_group = "DiagnosticHint" },
    ERROR = { duration = 5000, hl_group = "DiagnosticError" },
    INFO = { duration = 3000, hl_group = "DiagnosticInfo" },
    TRACE = { duration = 0, hl_group = "DiagnosticOk" },
    WARN = { duration = 5000, hl_group = "DiagnosticWarn" },
  })

  rawset(vim, "notify", function(msg, level, opts)
    mini_notify(msg, level, opts)
    if level == vim.log.levels.ERROR then
      vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
    end
  end)
end

--- Register autocmds that notify on LSP client attach/detach.
local function install_lsp_lifecycle_notifications()
  local group = vim.api.nvim_create_augroup("MiniNotifyLspLifecycle", {})
  local function notify(msg, level)
    rawget(vim, "notify")(msg, level)
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client then
        notify(client.name .. " attached", vim.log.levels.DEBUG)
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = group,
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client then
        notify(client.name .. " detached", vim.log.levels.WARN)
      end
    end,
  })
end

return {
  "nvim-mini/mini.notify",
  enabled = false,
  event = "VeryLazy",
  opts = {
    content = {
      sort = sort_notifications,
      format = format_notification,
    },
    lsp_progress = {
      enable = true,
      duration_last = 1000,
    },
    window = {
      config = window_position,
      max_width_share = 0.33,
      winblend = 25,
    },
  },
  config = function(_, opts)
    local notify = require("mini.notify")
    notify.setup(opts)
    install_notify_levels(notify)
    install_lsp_lifecycle_notifications()
  end,
}