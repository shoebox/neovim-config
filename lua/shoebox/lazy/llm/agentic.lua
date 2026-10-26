local _sessions = {}
local LAYA_ENABLED = false
local _prompt_queue = {}

local LAYA_MODELS_BY_PROVIDER = {
  ["cursor-acp"] = {
    trivial = { reasoning = "low", fast = true },
    bug_fix = { reasoning = "high", fast = false },
    feature = { reasoning = "medium", fast = false },
    refactoring = { reasoning = "high", fast = false },
    testing = { reasoning = "medium", fast = true },
    documentation = { reasoning = "low", fast = true },
    configuration = { reasoning = "medium", fast = true },
    ops_deployment = { reasoning = "high", fast = false },
    styling = { reasoning = "low", fast = true },
    explanation = { reasoning = "low", fast = true },
    performance = { reasoning = "high", fast = false },
  },
  ["copilot-acp"] = {
    trivial = "gpt-5.4-mini",
    bug_fix = "claude-sonnet-5.5",
    feature = "claude-sonnet-5.5",
    refactoring = "claude-sonnet-5.5",
    testing = "claude-sonnet-5.5",
    documentation = "gpt-5.4-mini",
    configuration = "gpt-5.4-mini",
    ops_deployment = "claude-sonnet-5.5",
    styling = "gpt-5.4-mini",
    explanation = "gpt-5.4-mini",
    performance = "gpt-6.1-sol",
    quick_edit = "gpt-5.4-mini",
    implementation = "claude-sonnet-5.5",
    debugging = "claude-sonnet-5.5",
    architecture = "gpt-6.1-sol",
    review = "gpt-6.1-sol",
    advanced = "gpt-6.1-sol",
  },
}

-- Live session state mirrored to the Herd overview, keyed by session_id:
-- { state, provider, prompt, cwd, tmux_target }. tmux can't see sessions
-- running inside nvim, so each transition is published to disk for the picker.
local _herd = {}

-- Agentic widget buffers: disable optional plugins that hurt streaming perf.
local AGENTIC_FTS = {
  "AgenticChat",
  "AgenticInput",
  "AgenticFiles",
  "AgenticTodos",
  "AgenticCode",
  "AgenticDiagnostics",
}

-- render-markdown reads the treesitter tree to place its decorations, so it
-- needs a live parser. Leave treesitter running on the chat/input buffers;
-- lighten the other panels as before.
local RENDER_MD_FTS = {
  AgenticChat = true,
  AgenticInput = true,
}

local function lighten_agentic_buffer(buf)
  vim.b[buf].minihipatterns_disable = true
  vim.b[buf].minidiff_disable = true
  pcall(function()
    require("mini.hipatterns").disable(buf)
  end)
  pcall(function()
    require("mini.diff").disable(buf)
  end)
  vim.bo[buf].indentexpr = ""
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win].colorcolumn = ""
  end
  -- Keep treesitter alive where render-markdown renders; stopping it there
  -- detaches the parser and kills all markdown decorations.
  if RENDER_MD_FTS[vim.bo[buf].filetype] then
    return
  end
  -- nvim-treesitter may attach on the same FileType event; stop again after it runs.
  pcall(vim.treesitter.stop, buf)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.treesitter.stop, buf)
    end
  end)
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.treesitter.stop, buf)
    end
  end, 600)
end

local _notify_paused = 0
local _notify_orig = nil
local _notify_sessions = {}

local function notifications_pause(session_id)
  if _notify_sessions[session_id] then
    return
  end
  _notify_sessions[session_id] = true
  _notify_paused = _notify_paused + 1
  if _notify_paused > 1 then
    return
  end
  _notify_orig = vim.notify
  vim.notify = function() end
end

--- Get the agentic widget for a given tab page, if it exists.
local function get_widget(tab_page_id)
  local ok, registry = pcall(require, "agentic.session_registry")
  if not ok then
    return nil
  end
  local session = registry.sessions[tab_page_id]
  return session and session.widget or nil
end

--- Pause render-markdown for the whole response, including hidden sessions.
local function set_chat_render_md(data, enable)
  local ok, registry = pcall(require, "agentic.session_registry")
  if not ok then
    return
  end
  local session = registry.sessions[data.session_key]
  local widget = session and session.widget
  local buf = widget and widget.buf_nrs and widget.buf_nrs.chat
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.b[buf].agentic_render_md_paused = not enable
  local loaded, manager = pcall(require, "render-markdown.core.manager")
  if not loaded or not manager.attached(buf) then
    return
  end
  if not enable then
    if vim.b[buf].agentic_render_md_enabled == nil then
      vim.b[buf].agentic_render_md_enabled = require("render-markdown.state").get(buf).enabled
    end
    manager.set_buf(buf, false)
    local ui = require("render-markdown.core.ui")
    vim.api.nvim_buf_clear_namespace(buf, ui.ns, 0, -1)
  elseif vim.b[buf].agentic_render_md_enabled ~= nil then
    manager.set_buf(buf, vim.b[buf].agentic_render_md_enabled)
    vim.b[buf].agentic_render_md_enabled = nil
  end
end

local function notifications_resume(session_id)
  if not _notify_sessions[session_id] then
    return
  end
  _notify_sessions[session_id] = nil
  _notify_paused = _notify_paused - 1
  if _notify_paused > 0 then
    return
  end
  if _notify_orig then
    vim.notify = _notify_orig
    _notify_orig = nil
  end
end

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

--- Resolve the git worktree (or repo) folder asynchronously. The callback
--- receives (name, toplevel): the folder's basename and its absolute path.
local function resolve_repo_name(callback)
  vim.system({ "git", "rev-parse", "--show-toplevel" }, {}, function(result)
    local toplevel = vim.trim(result.stdout or "")
    local name = toplevel ~= "" and vim.fn.fnamemodify(toplevel, ":t") or ""
    callback(name, toplevel)
  end)
end

--- Capture the current tmux pane target (session:window.pane) for Herd focus.
local function capture_tmux_target(callback)
  vim.system(
    { "tmux", "display-message", "-p", "#{session_name}:#{window_index}.#{pane_index}" },
    {},
    function(result)
      callback(vim.trim(result.stdout or ""))
    end
  )
end

local _herd_publish_pending = false
local _herd_publish_scheduled = false

local function publish_herd()
  _herd_publish_pending = true
  if _herd_publish_scheduled then
    return
  end
  _herd_publish_scheduled = true
  vim.schedule(function()
    while _herd_publish_pending do
      _herd_publish_pending = false
      local ok, herd = pcall(require, "shoebox.extras.herd")
      if ok and herd.publish then
        herd.publish(_herd)
      end
    end
    _herd_publish_scheduled = false
  end)
end

--- Resolve the provider name (e.g. "cursor-acp") for a session's tab page.
--- Falls back to "agentic" when the registry or agent isn't reachable.
local function get_provider_name(tab_page_id)
  local ok, registry = pcall(require, "agentic.session_registry")
  if not ok then
    return "agentic"
  end
  local session = registry.sessions[tab_page_id]
  local name = session
    and session.agent
    and session.agent.provider_config
    and session.agent.provider_config.name
  return name or "agentic"
end

--- Start tracking a session: record timing, prompt, tmux target, repo name,
--- and update the chat header.
local function track_session(session_id, prompt, tab_page_id)
  local session = {
    prompt = truncate_prompt(prompt),
    tab_page_id = tab_page_id,
  }
  _sessions[session_id] = session

  -- Mirror to Herd as working; cwd/tmux_target backfill via the async resolves.
  local herd = {
    state = "working",
    provider = get_provider_name(tab_page_id),
    prompt = truncate_prompt(prompt, 60),
    cwd = "",
    tmux_target = "",
  }
  _herd[session_id] = herd
  publish_herd()

  -- Capture context asynchronously for Herd.
  resolve_repo_name(function(_, toplevel)
    if _herd[session_id] ~= herd then
      return
    end
    herd.cwd = toplevel or ""
    publish_herd()
  end)
  capture_tmux_target(function(target)
    if _herd[session_id] ~= herd then
      return
    end
    herd.tmux_target = target
    publish_herd()
  end)

  local widget = get_widget(tab_page_id)
  if widget then
    widget:render_header("chat", "▶ " .. truncate_prompt(prompt, 40))
  end
end

--- Complete a tracked session: clear header and update Herd state.
local function complete_session(session_id, success)
  local session = _sessions[session_id]
  _sessions[session_id] = nil

  -- Session stays in the Herd as idle — it's still open, just not working.
  if _herd[session_id] then
    _herd[session_id].state = "idle"
    _herd[session_id].blocked_detail = nil
    publish_herd()
  end

  if not session then
    return
  end
  local widget = get_widget(session.tab_page_id)
  if widget then
    local icon = success and "✔" or "✖"
    widget:render_header("chat", icon .. " Done")
  end
end

local function prune_session_state()
  local registry = package.loaded["agentic.session_registry"]
  if not registry then
    return
  end
  local live = {}
  for _, session in pairs(registry.sessions) do
    if not session._destroyed and session.session_id then
      live[session.session_id] = session
    end
  end
  local changed = false
  for id in pairs(_herd) do
    if not live[id] then
      _herd[id] = nil
      _sessions[id] = nil
      notifications_resume(id)
      changed = true
    end
  end
  for i = #_prompt_queue, 1, -1 do
    local session = _prompt_queue[i].session
    if session._destroyed or live[session.session_id] ~= session then
      table.remove(_prompt_queue, i)
    end
  end
  if changed then
    publish_herd()
  end
end

local function queue_prompt()
  prune_session_state()
  local session = require("agentic.session_registry").current()
  if not session then
    vim.notify("No visible Agentic session", vim.log.levels.WARN)
    return
  end

  local buf = session.widget.buf_nrs.input
  local prompt =
    table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"):match("^%s*(.-)%s*$")
  if not prompt or not prompt:match("%S") then
    return
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  if not session.is_generating then
    session:_handle_input_submit(prompt)
    return
  end

  _prompt_queue[#_prompt_queue + 1] = {
    prompt = prompt,
    session = session,
  }
  vim.notify(string.format("Queued Agentic prompt #%d", #_prompt_queue), vim.log.levels.INFO)
end

local function submit_queued_prompt(session_id)
  prune_session_state()
  for i, queued in ipairs(_prompt_queue) do
    if queued.session.session_id == session_id then
      table.remove(_prompt_queue, i)
      vim.schedule(function()
        if not queued.session._destroyed and queued.session.session_id == session_id then
          queued.session:_handle_input_submit(queued.prompt)
        end
      end)
      return
    end
  end
end

--- Best-effort label for an ACP permission request (command, path, title).
--- Mirrors agentic's acp_client argument extraction for execute/edit tools.
local function format_permission_detail(tool_call)
  if not tool_call then
    return "permission required"
  end

  local kind = tool_call.kind or "tool"
  local raw = type(tool_call.rawInput) == "table" and tool_call.rawInput or nil
  local detail

  if raw and type(raw.command) == "string" and raw.command ~= "" then
    detail = raw.command
  else
    local parts = {}
    if tool_call.title and tool_call.title ~= "" then
      parts[#parts + 1] = tool_call.title
    end
    if raw then
      local path = raw.file_path or raw.filePath
      if type(path) == "string" and path ~= "" then
        parts[#parts + 1] = path
      end
    end
    if type(tool_call.locations) == "table" then
      local loc = tool_call.locations[1]
      if loc and loc.path then
        parts[#parts + 1] = loc.path
      end
    end
    detail = #parts > 0 and table.concat(parts, " · ") or tool_call.toolCallId or "?"
  end

  detail = detail:gsub("[\r\n]+", " "):gsub("%s+", " ")
  return string.format("%s(%s)", kind, detail)
end

local function notify_permission(msg)
  local notify = _notify_orig or vim.notify
  notify(msg, vim.log.levels.WARN, { title = "Agentic permission" })
end

local function resume_working(session_id, tab_page_id, session_key)
  local registry = package.loaded["agentic.session_registry"]
  local session = registry and registry.sessions[session_key]
  if not session or not session.is_generating or session._destroyed then
    return
  end
  if session.permission_manager and session.permission_manager:has_pending() then
    return
  end
  local herd = _herd[session_id]
  if not herd or herd.state == "working" then
    return
  end
  herd.state = "working"
  herd.blocked_detail = nil
  publish_herd()

  local tracked = _sessions[session_id]
  local widget = tab_page_id and get_widget(tab_page_id)
  if tracked and widget then
    widget:render_header("chat", "▶ " .. truncate_prompt(tracked.prompt, 40))
  end
end

--- Mark a tracked session as blocked (waiting on a permission prompt) in the
--- Herd overview. Ignored if the session isn't tracked yet.
local function mark_blocked(session_id, detail, tab_page_id)
  if _herd[session_id] then
    _herd[session_id].state = "blocked"
    _herd[session_id].blocked_detail = detail
    publish_herd()
  end

  if detail and tab_page_id then
    local widget = get_widget(tab_page_id)
    if widget then
      widget:render_header("chat", "⚠ " .. truncate_prompt(detail, 60))
    end
  end
end

--- Build a winbar tab bar listing every open Agentic session. The session
--- visible in the current tabpage is highlighted; the rest are dimmed. Each tab
--- shows `<key>:<title>`, the title being the session's chat title (or its
--- tracked prompt, or "Untitled"). Returns "" when no session exists so the
--- winbar stays clear.
local function session_tabline()
  local ok, registry = pcall(require, "agentic.session_registry")
  if not ok then
    return ""
  end

  local sessions = registry.list()
  if #sessions == 0 then
    return ""
  end

  -- Stable left-to-right order by key, independent of recency.
  table.sort(sessions, function(a, b)
    return (a.session_key or 0) < (b.session_key or 0)
  end)

  local current_tab = vim.api.nvim_get_current_tabpage()
  local active_hl = "AgenticTitle"
  local inactive_hl = "Comment"

  local pieces = {}
  for _, sm in ipairs(sessions) do
    local title = sm.chat_history and sm.chat_history.title or ""
    if title == "" then
      local tracked = _sessions[sm.session_id]
      title = (tracked and tracked.prompt ~= "" and tracked.prompt) or "Untitled"
    end

    local is_active = sm.widget and sm.widget:get_visible_tab_id() == current_tab
    local hl = is_active and active_hl or inactive_hl
    local herd_entry = _herd[sm.session_id]
    local blocked = herd_entry and herd_entry.state == "blocked" and herd_entry.blocked_detail
    local label = blocked
        and string.format(
          " %d:%s ⚠ %s ",
          sm.session_key or 0,
          truncate_prompt(title, 16),
          truncate_prompt(herd_entry.blocked_detail, 24)
        )
      or string.format(" %d:%s ", sm.session_key or 0, truncate_prompt(title, 24))
    pieces[#pieces + 1] = string.format("%%#%s#%s%%#Normal#", hl, label)
  end

  return table.concat(pieces, "")
end

--- Chat buffer name (shown in lualine): `<provider> <model> <context> <cost> <prompt>`.
--- The prompt rides in `parts.context`, set by track_session's render_header call.
local function format_chat_buffer_name(parts, session_state)
  local pieces = {}
  local function add(v)
    if v ~= nil and v ~= "" then
      pieces[#pieces + 1] = v
    end
  end

  if session_state then
    add(session_state:get_provider_name())
    add(session_state:get_model_name() or session_state:get_model_id())

    local used = session_state:get_context_used()
    local size = session_state:get_context_size()
    if used ~= nil and size ~= nil then
      add(string.format("ctx %s/%s", used, size))
    end

    local cost = session_state:get_cost_amount_raw()
    if cost and cost ~= 0 then
      local amount = session_state:get_cost_amount()
      local currency = session_state:get_cost_currency()
      add(currency and (currency .. " " .. amount) or ("$" .. amount))
    end
  end

  add(parts and parts.context)

  if #pieces == 0 then
    return parts and parts.title or nil
  end

  return table.concat(pieces, " ")
end

return {
  {
    "carlos-algms/agentic.nvim",
    dependencies = { "j-hui/fidget.nvim" },
    opts = {
      debug = false,
      provider = "cursor-acp",
      acp_providers = {
        ["copilot-acp"] = {
          command = "copilot",
          args = { "--acp", "--stdio", "--allow-all-tools" },
          env = {},
          -- Start in Auto; Laya selects an explicit model for classified prompts.
          initial_model = "auto",
        },
        ["cursor-acp"] = {
          command = "cursor-agent",
          args = { "--yolo", "acp" },
          -- cursor-agent is a Node CLI under the hood; very long chats grow the
          -- V8 heap unbounded. Cap old-space so it OOMs a stale process instead
          -- of ballooning RSS for the life of the nvim session (same tradeoff
          -- as auggie-acp below).
          -- env = { NODE_OPTIONS = "--max-old-space-size=1024" },
        },
        ["opencode-acp"] = {
          command = "opencode",
          args = { "acp" },
          env = {},
        },
      },
      tool_calls = {
        title = { max_length = 0 },
      },
      windows = {
        todos = { display = false },
        position = "right",
        chat = {
          win_opts = { winfixwidth = false },
          buffer_name = format_chat_buffer_name,
        },
      },
      keymaps = {
        widget = {
          switch_model = "<localLeader>m",
        },
      },
      folding = {
        tool_calls = { enabled = false },
      },
      -- Chat winbar shows a tab bar of open sessions; the plain title still
      -- lands in the buffer name (shown in lualine). Input winbar stays cleared.
      headers = {
        chat = function()
          return session_tabline()
        end,
        input = function()
          return ""
        end,
      },
      hooks = {
        on_prompt_submit = function(data)
          prune_session_state()
          track_session(data.session_id, data.prompt, data.tab_page_id)
          set_chat_render_md(data, false)
          notifications_pause(data.session_id)
        end,
        on_response_complete = function(data)
          notifications_resume(data.session_id)
          set_chat_render_md(data, true)
          complete_session(data.session_id, data.success)
          submit_queued_prompt(data.session_id)
        end,
        on_session_update = function(data)
          local update = data.update
          if not update then
            return
          end
          local kind = update.sessionUpdate
          if kind == "agent_message_chunk" or kind == "agent_thought_chunk" then
            resume_working(data.session_id, data.tab_page_id, data.session_key)
          end
        end,
        on_request_permission = function(data)
          local detail = format_permission_detail(data.request and data.request.toolCall)
          mark_blocked(data.session_id, detail, data.tab_page_id)
          notify_permission("Allow " .. detail .. "?")
        end,
      },
      spinner_chars = {
        generating = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        thinking = { "⢎ ", "⠎⠁", "⠊⠑", "⠈⠱", " ⡱", "⢀⡰", "⢄⡠", "⢆⡀" },
      },
    },

    config = function(_, opts)
      -- Upstream can classify unpaired additions as modifications in equal-sized blocks.
      local writer = require("agentic.ui.message_writer")
      local prepare_block_lines = writer._prepare_block_lines
      writer._prepare_block_lines = function(self, block)
        local lines, ranges = prepare_block_lines(self, block)
        for _, range in ipairs(ranges) do
          if range.type == "new_modification" and range.old_line == nil then
            range.type = "new"
          end
        end
        return lines, ranges
      end
      require("agentic").setup(opts)
      require("shoebox.extras.agentic_commands").setup()
    end,

    init = function()
      if LAYA_ENABLED then
        local laya = require("shoebox.extras.laya")
        laya.setup({
          debug = vim.g.shoebox_laya_debug or false,
          threshold = vim.g.shoebox_laya_threshold,
          models = vim.g.shoebox_laya_models or {},
          models_by_provider = vim.g.shoebox_laya_models_by_provider or LAYA_MODELS_BY_PROVIDER,
        })
        laya.init()
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = AGENTIC_FTS,
        callback = function(ev)
          lighten_agentic_buffer(ev.buf)
          vim.keymap.set({ "n", "i", "t" }, "<Esc><Esc>", function()
            require("agentic").stop_generation()
          end, { buffer = ev.buf, desc = "Stop Agentic generation" })
        end,
      })

      vim.api.nvim_create_autocmd("BufWipeout", {
        callback = function(ev)
          if vim.bo[ev.buf].filetype == "AgenticChat" then
            -- Registry removal precedes buffer destruction; defer until teardown finishes.
            vim.schedule(prune_session_state)
          end
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "AgenticInput",
        callback = function(ev)
          vim.keymap.set({ "i", "n" }, "<C-q>", function()
            vim.cmd("stopinsert")
            queue_prompt()
          end, {
            buffer = ev.buf,
            desc = "Agentic: queue prompt",
          })
        end,
      })

      -- Hidden chat float attaches later; re-apply when an agentic buf enters a window.
      vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew" }, {
        callback = function(ev)
          if vim.tbl_contains(AGENTIC_FTS, vim.bo[ev.buf].filetype) then
            lighten_agentic_buffer(ev.buf)
          end
        end,
      })

      -- Drop this nvim's Herd state file on exit so the picker doesn't show a
      -- dead session (read_agentic prunes stale files too, as a backstop).
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          local ok, herd = pcall(require, "shoebox.extras.herd")
          if ok and herd.clear then
            herd.clear()
          end
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
        "<leader>an", -- ai New (uses current provider)
        function()
          require("agentic").new_session()
        end,
        desc = "Agentic New session",
        mode = { "n", "v", "i" },
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
        "<leader>ak", -- ai Keep going
        function()
          local session = require("agentic.session_registry").current()
          if session then
            session:_handle_input_submit("continue")
          else
            vim.notify("No visible Agentic session", vim.log.levels.WARN)
          end
        end,
        desc = "Agentic continue",
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
