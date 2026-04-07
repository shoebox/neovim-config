local _sessions = {}
local _focused = true

local NOTIFICATION_THRESHOLD_S = 30

--- Truncate a prompt string to a maximum length, appending "…" if truncated.
local function truncate_prompt(prompt, max_len)
  max_len = max_len or 50
  if not prompt or #prompt == 0 then
    return ""
  end
  if #prompt > max_len then
    return prompt:sub(1, max_len) .. "…"
  end
  return prompt
end

--- Send a macOS notification with the tmux pane title as the notification title.
local function send_notification(status, minutes, subtitle)
  vim.system({ "tmux", "display-message", "-p", "#T" }, {}, function(result)
    local pane_title = vim.trim(result.stdout or "tmux")
    local title = "🤖 " .. pane_title
    vim.schedule(function()
      vim.system({
        "osascript",
        "-e",
        string.format(
          'display notification "Job %s after %s min" with title "%s" subtitle "%s"',
          status,
          minutes,
          title,
          subtitle
        ),
      })
    end)
  end)
end

--- Start tracking a session: record timing and prompt.
local function track_session(session_id, prompt)
  _sessions[session_id] = {
    start_time = vim.uv.hrtime(),
    prompt = truncate_prompt(prompt),
  }
end

--- Complete a tracked session: optionally send a system notification.
local function complete_session(session_id, success)
  local session = _sessions[session_id]
  if not session then
    return
  end
  _sessions[session_id] = nil

  local elapsed_s = (vim.uv.hrtime() - session.start_time) / 1e9
  if elapsed_s >= NOTIFICATION_THRESHOLD_S and not _focused then
    local status = success and "completed" or "failed"
    local minutes = string.format("%.1f", elapsed_s / 60)
    send_notification(status, minutes, session.prompt)
  end
end

return {
  {
    "carlos-algms/agentic.nvim",
    opts = {
      provider = "auggie-acp",
      headers = {
        chat = function(parts)
          local header = parts.title
          if parts.context then
            header = header .. " [" .. parts.context .. "]"
          end
          if parts.suffix then
            header = header .. " • " .. parts.suffix
          end
          return header
        end,
      },
      hooks = {
        on_prompt_submit = function(data)
          track_session(data.session_id, data.prompt)
        end,
        on_response_complete = function(data)
          complete_session(data.session_id, data.success)
        end,
      },
    },

    init = function()
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          _focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          _focused = false
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "AgenticChat", "AgenticInput", "AgenticFiles" },
        callback = function(ev)
          vim.keymap.set("n", "<Esc>", function()
            require("agentic").stop_generation()
          end, { buffer = ev.buf, desc = "Stop Agentic generation" })
        end,
      })
    end,

    -- these are just suggested keymaps; customize as desired
    keys = {
      {
        "<C-\\>",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v", "i" },
        desc = "Toggle Agentic Chat",
      },
      {
        "<C-'>",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Add file or selection to Agentic to Context",
      },
      {
        "<C-,>",
        function()
          require("agentic").new_session()
        end,
        mode = { "n", "v", "i" },
        desc = "New Agentic Session",
      },
      {
        "<leader>air", -- ai Restore
        function()
          require("agentic").restore_session()
        end,
        desc = "Agentic Restore session",
        silent = true,
        mode = { "n", "v", "i" },
      },
      {
        "<leader>ad", -- ai Diagnostics
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        desc = "Add current line diagnostic to Agentic",
        mode = { "n" },
      },
      {
        "<leader>aD", -- ai all Diagnostics
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        desc = "Add all buffer diagnostics to Agentic",
        mode = { "n" },
      },
    },
  },
}
