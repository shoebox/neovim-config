-- Herd: agent overview via Telescope. Tmux pane scrape + agentic.nvim sessions.

local M = {}

local api = vim.api

local AGENTS = {
  "claude", "codex", "cursor-agent", "opencode", "auggie",
  "grok", "aider", "gemini", "goose", "amp",
}

local BLOCKED = {
  "Do you want to proceed", "Allow this action", "Approve", "[y/N]", "[Y/n]",
  "(y/n)", "❯ 1. Yes", "Continue?", "Waiting for your input",
}
local WORKING = {
  "esc to interrupt", "Esc to interrupt", "Thinking", "Generating", "Working",
  "Baking", "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏",
}

local STATE = {
  blocked = { icon = "●", hl = "DiagnosticError", order = 1 },
  working = { icon = "◐", hl = "DiagnosticWarn", order = 2 },
  idle = { icon = "○", hl = "Comment", order = 3 },
  done = { icon = "○", hl = "Comment", order = 3 },
  unknown = { icon = "?", hl = "Comment", order = 3 },
}

local PROVIDERS = {
  { "cursor-agent", "󰝮", "Special", "Cursor" },
  { "cursor-acp", "󰝮", "Special", "Cursor" },
  { "cursor", "󰝮", "Special", "Cursor" },
  { "claude", "󰭤", "Constant", "Claude" },
  { "codex", "󰚩", "Function", "Codex" },
  { "opencode", "󰘦", "String", "OpenCode" },
  { "auggie", "󰗚", "Identifier", "Auggie" },
  { "grok", "󰭻", "WarningMsg", "Grok" },
  { "gemini", "󰚰", "Keyword", "Gemini" },
  { "aider", "󰶫", "Type", "Aider" },
  { "goose", "󰫍", "Title", "Goose" },
  { "agentic", "󰚩", "Special", "Agentic" },
}

local STATE_DIR = vim.fn.stdpath("cache") .. "/herd"
local LOG_LINES = 80
local CACHE_SUMMARY_MAX = 80

local FMT = "#{session_name}:#{window_index}.#{pane_index}\t"
  .. "#{pane_current_command}\t#{pane_current_path}"

local function tmux(args)
  local out = vim.fn.systemlist(vim.list_extend({ "tmux" }, args))
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return out
end

local function contains_any(text, needles)
  for _, n in ipairs(needles) do
    if text:find(n, 1, true) then
      return true
    end
  end
  return false
end

local function is_agent(cmd, agents)
  return contains_any(cmd, agents)
end

local function classify(capture)
  if contains_any(capture, BLOCKED) then
    return "blocked"
  end
  if contains_any(capture, WORKING) then
    return "working"
  end
  return "idle"
end

local function last_line(capture)
  local last = ""
  for line in (capture .. "\n"):gmatch("(.-)\n") do
    local t = vim.trim(line)
    if t ~= "" then
      last = t
    end
  end
  return last
end

local function one_line(text)
  return vim.trim((text or ""):gsub("[\r\n]+", " "))
end

local function truncate_summary(text)
  text = one_line(text)
  if text == "" then
    return ""
  end
  if #text > CACHE_SUMMARY_MAX then
    return text:sub(1, CACHE_SUMMARY_MAX) .. "…"
  end
  return text
end

--- Cross-instance cache: state + routing metadata only (no chat tails or full prompts).
local function session_cache_record(entry)
  local summary = ""
  if entry.state == "blocked" and entry.blocked_detail and entry.blocked_detail ~= "" then
    summary = truncate_summary(entry.blocked_detail)
  elseif entry.summary and entry.summary ~= "" then
    summary = truncate_summary(entry.summary)
  elseif entry.prompt and entry.prompt ~= "" then
    summary = truncate_summary(entry.prompt)
  end
  return {
    state = entry.state or "idle",
    provider = entry.provider or "agentic",
    cwd = entry.cwd or "",
    tmux_target = entry.tmux_target or "",
    summary = summary,
  }
end

local function legacy_cache_summary(session)
  if session.state == "blocked" and session.blocked_detail and session.blocked_detail ~= "" then
    return truncate_summary(session.blocked_detail)
  end
  if session.summary and session.summary ~= "" then
    return truncate_summary(session.summary)
  end
  if session.prompt and session.prompt ~= "" then
    return truncate_summary(session.prompt)
  end
  if session.log and session.log ~= "" then
    return truncate_summary(last_line(session.log))
  end
  return ""
end

local function tail_text(text, max_lines)
  local lines = vim.split((text or ""):gsub("\27%[[0-9;]*[A-Za-z]", ""), "\n", { plain = true })
  if #lines > max_lines then
    lines = vim.list_slice(lines, #lines - max_lines + 1, #lines)
  end
  return table.concat(lines, "\n")
end

local function buf_tail(bufnr, max_lines)
  if not bufnr or not api.nvim_buf_is_valid(bufnr) then
    return ""
  end
  local n = api.nvim_buf_line_count(bufnr)
  local from = math.max(0, n - max_lines)
  return table.concat(api.nvim_buf_get_lines(bufnr, from, n, false), "\n")
end

local function parse_tmux_target(target)
  if not target then
    return nil, nil
  end
  local session, rest = target:match("^([^:]+):(.+)$")
  if not session then
    return target, nil
  end
  local window, pane = rest:match("^(%d+)%.(%d+)$")
  return session, window and (window .. "." .. pane) or rest
end

local function normalize_state(state)
  state = state or "idle"
  if state == "done" or state == "unknown" or not STATE[state] then
    state = "idle"
  end
  return state
end

local function provider(cmd)
  local id = (cmd or ""):lower()
  for _, p in ipairs(PROVIDERS) do
    if id:find(p[1], 1, true) then
      return { icon = p[2], hl = p[3], name = p[4] }
    end
  end
  return { icon = "◇", hl = "Comment", name = cmd or "agent" }
end

local function make_item(fields)
  fields.state = normalize_state(fields.state)
  fields.workspace = fields.workspace or fields.cwd or ""
  fields.tab = fields.tab or ""
  fields.log = fields.log or ""
  fields.summary = one_line((fields.summary and fields.summary ~= "") and fields.summary or last_line(fields.log))
  fields.provider = provider(fields.cmd)
  return fields
end

local function group_items(items)
  table.sort(items, function(a, b)
    if a.workspace ~= b.workspace then
      return a.workspace < b.workspace
    end
    if a.state ~= b.state then
      return STATE[a.state].order < STATE[b.state].order
    end
    return (a.target or a.cmd) < (b.target or b.cmd)
  end)

  local groups, order = {}, {}
  for _, item in ipairs(items) do
    local ws = item.workspace ~= "" and item.workspace or "(unknown)"
    item.workspace = ws
    if not groups[ws] then
      groups[ws] = {}
      order[#order + 1] = ws
    end
    groups[ws][#groups[ws] + 1] = item
  end

  local out = {}
  for _, ws in ipairs(order) do
    out[#out + 1] = { workspace = ws, agents = groups[ws] }
  end
  return out
end

local function flatten_groups(groups)
  local items = {}
  for _, group in ipairs(groups) do
    vim.list_extend(items, group.agents)
  end
  return items
end

local function entry_display(item)
  local p = item.provider or provider(item.cmd)
  local s = STATE[item.state] or STATE.idle
  local tab = item.tab ~= "" and (" · " .. item.tab) or ""
  local summary = item.summary ~= "" and (" — " .. item.summary) or ""
  return string.format("%s  %s %s %s%s%s", item.workspace, p.icon, s.icon, item.cmd, tab, summary)
end

local function entry_ordinal(item)
  local p = item.provider or provider(item.cmd)
  return table.concat({
    item.workspace, item.cmd, p.name, item.state, item.tab, item.summary,
  }, " ")
end

local function read_local_agentic()
  local path = STATE_DIR .. "/" .. vim.fn.getpid() .. ".json"
  local published = {}
  if vim.fn.filereadable(path) == 1 then
    local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
    if ok and type(data) == "table" and data.sessions then
      published = data.sessions
    end
  end

  local ok, registry = pcall(require, "agentic.session_registry")
  if not ok then
    return {}
  end

  local items = {}
  for _, sm in pairs(registry.sessions or {}) do
    if sm and sm.widget and sm.widget.buf_nrs then
      local sid = sm.session_id or ("tab-" .. tostring(sm.session_key or ""))
      local pub = published[sid] or {}
      local prov = sm.agent and sm.agent.provider_config and sm.agent.provider_config.name
        or pub.provider
        or "agentic"
      local cwd = pub.cwd or ""
      local state = "idle"
      if sm.permission_manager and sm.permission_manager:has_pending() then
        state = "blocked"
      elseif sm.is_generating then
        state = "working"
      end
      local workspace, tab = parse_tmux_target(pub.tmux_target)
      local log = buf_tail(sm.widget.buf_nrs.chat, LOG_LINES)
      items[#items + 1] = make_item({
        kind = "agentic",
        session_id = sid,
        target = pub.tmux_target ~= "" and pub.tmux_target or nil,
        cmd = prov,
        workspace = workspace or (cwd ~= "" and vim.fn.fnamemodify(cwd, ":~") or "(unknown)"),
        tab = tab or "",
        cwd = cwd ~= "" and vim.fn.fnamemodify(cwd, ":~") or "(unknown)",
        state = state,
        summary = (pub.summary and pub.summary ~= "") and pub.summary or last_line(log),
        log = log,
      })
    end
  end
  return items
end

local _pending_publish = nil
local _publish_scheduled = false
local _dir_ready = false

local function ensure_state_dir()
  if _dir_ready then
    return true
  end
  if vim.uv.fs_stat(STATE_DIR) then
    _dir_ready = true
    return true
  end
  local ok, err = vim.uv.fs_mkdir(STATE_DIR, 493)
  if ok or err == "EEXIST" then
    _dir_ready = true
    return true
  end
  return false
end

local function write_publish(sessions)
  if not ensure_state_dir() then
    return
  end
  local path = STATE_DIR .. "/" .. vim.fn.getpid() .. ".json"
  local sanitized = {}
  for id, entry in pairs(sessions or {}) do
    if type(entry) == "table" then
      sanitized[id] = session_cache_record(entry)
    end
  end
  local ok, body = pcall(vim.json.encode, { pid = vim.fn.getpid(), sessions = sanitized })
  if not ok then
    return
  end
  local tmp = path .. ".tmp"
  local fd = vim.uv.fs_open(tmp, "w", 384)
  if not fd then
    return
  end
  vim.uv.fs_write(fd, body)
  vim.uv.fs_close(fd)
  vim.uv.fs_rename(tmp, path)
end

function M.publish(sessions)
  _pending_publish = sessions
  if _publish_scheduled then
    return
  end
  _publish_scheduled = true
  vim.schedule(function()
    while _pending_publish do
      local data = _pending_publish
      _pending_publish = nil
      write_publish(data)
    end
    _publish_scheduled = false
  end)
end

function M.clear()
  vim.schedule(function()
    vim.uv.fs_unlink(STATE_DIR .. "/" .. vim.fn.getpid() .. ".json")
  end)
end

local function read_agentic()
  local my_pid = vim.fn.getpid()
  local items = {}
  if vim.fn.isdirectory(STATE_DIR) == 0 then
    return read_local_agentic()
  end
  for name, kind in vim.fs.dir(STATE_DIR) do
    if kind == "file" and name:match("%.json$") then
      local pid = tonumber(name:match("^(%d+)%.json$"))
      if pid == my_pid then
        vim.list_extend(items, read_local_agentic())
      elseif pid and vim.uv.kill(pid, 0) then
        local path = STATE_DIR .. "/" .. name
        local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
        if ok and type(data) == "table" and data.sessions then
          for _, s in pairs(data.sessions) do
            local cwd = s.cwd or ""
            local workspace, tab = parse_tmux_target(s.tmux_target)
            local summary = legacy_cache_summary(s)
            items[#items + 1] = make_item({
              kind = "agentic",
              target = s.tmux_target ~= "" and s.tmux_target or nil,
              cmd = s.provider or "agentic",
              workspace = workspace or (cwd ~= "" and vim.fn.fnamemodify(cwd, ":~") or "(unknown)"),
              tab = tab or "",
              cwd = cwd ~= "" and vim.fn.fnamemodify(cwd, ":~") or "(unknown)",
              state = STATE[s.state] and s.state or "idle",
              summary = summary,
              log = "",
            })
          end
        end
      else
        vim.uv.fs_unlink(STATE_DIR .. "/" .. name)
      end
    end
  end
  return items
end

local function collect_tmux(agents)
  local panes = tmux({ "list-panes", "-a", "-F", FMT })
  if not panes then
    return {}
  end
  local items = {}
  for _, line in ipairs(panes) do
    local target, cmd, cwd = line:match("^(.-)\t(.-)\t(.*)$")
    if target and is_agent(cmd, agents) then
      local workspace, tab = parse_tmux_target(target)
      local raw = table.concat(tmux({ "capture-pane", "-p", "-t", target, "-S", "-" .. LOG_LINES }) or {}, "\n")
      local log = tail_text(raw, LOG_LINES)
      items[#items + 1] = make_item({
        kind = "tmux",
        target = target,
        cmd = cmd,
        workspace = workspace or vim.fn.fnamemodify(cwd, ":~"),
        tab = tab or "",
        cwd = vim.fn.fnamemodify(cwd, ":~"),
        state = classify(log),
        summary = last_line(log),
        log = log,
      })
    end
  end
  return items
end

local function collect(agents)
  local items = collect_tmux(agents)
  vim.list_extend(items, read_agentic())
  return group_items(items)
end

local function preview_lines(item)
  if not item then
    return { "(select an agent)" }, "log"
  end
  local p = item.provider or provider(item.cmd)
  local s = STATE[item.state] or STATE.idle
  local header = table.concat({
    p.icon .. " " .. p.name,
    s.icon .. " " .. item.state,
    item.workspace,
    item.tab ~= "" and item.tab or nil,
  }, "  ·  ")
  local log = item.log ~= "" and item.log
    or (item.summary ~= "" and item.summary or "(no output yet)")
  local lines = vim.list_extend({ header, string.rep("─", 72), "" }, vim.split(log, "\n", { plain = true }))
  local ft = item.kind == "agentic" and "markdown" or "log"
  return lines, ft
end

local function focus_item(item)
  if not item then
    return
  end
  if not item.target then
    return vim.notify("No focus target for this session", vim.log.levels.WARN, { title = "Herd" })
  end
  if (vim.env.TMUX or "") == "" then
    return vim.notify("Not inside tmux", vim.log.levels.WARN, { title = "Herd" })
  end
  tmux({ "switch-client", "-t", item.target })
  tmux({ "select-window", "-t", item.target:match("^(.+)%.") or item.target })
  tmux({ "select-pane", "-t", item.target })
end

local function send_message(item, text)
  if not item or text == "" then
    return false, "empty message"
  end

  if item.kind == "agentic" and item.session_id then
    local ok, registry = pcall(require, "agentic.session_registry")
    if ok then
      for _, sm in pairs(registry.sessions or {}) do
        if sm and sm.session_id == item.session_id then
          if sm:_handle_input_submit(text) then
            return true
          end
          return false, "agent is busy or cannot accept input"
        end
      end
    end
  end

  if item.target and (vim.env.TMUX or "") ~= "" then
    tmux({ "send-keys", "-t", item.target, "-l", text })
    tmux({ "send-keys", "-t", item.target, "Enter" })
    return true
  end

  return false, "no send target for this session"
end

local function prompt_send(item)
  if not item then
    return
  end
  local p = item.provider or provider(item.cmd)
  local label = string.format("Message to %s: ", p.name)
  local text = vim.fn.input(label)
  if text == "" then
    return
  end
  local ok, err = send_message(item, text)
  if ok then
    vim.notify("Sent to " .. p.name, vim.log.levels.INFO, { title = "Herd" })
  else
    vim.notify(err or "send failed", vim.log.levels.WARN, { title = "Herd" })
  end
end

function M.pick(agents)
  agents = agents or AGENTS

  local ok, telescope = pcall(require, "telescope")
  if not ok then
    return vim.notify("telescope.nvim not available", vim.log.levels.ERROR, { title = "Herd" })
  end

  local items = flatten_groups(collect(agents))
  if #items == 0 then
    return vim.notify("No agents found", vim.log.levels.INFO, { title = "Herd" })
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  local agent_previewer = previewers.new_buffer_previewer({
    title = " Output ",
    define_preview = function(self, entry)
      local lines, ft = preview_lines(entry and entry.value)
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      vim.bo[self.state.bufnr].filetype = ft
    end,
  })

  pickers.new({}, {
    prompt_title = "Agent Herd",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        width = 0.92,
        height = 0.9,
        preview_width = 0.58,
      },
    },
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        return {
          value = item,
          display = entry_display(item),
          ordinal = entry_ordinal(item),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = agent_previewer,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if entry then
          focus_item(entry.value)
        end
      end)
      local function send_selected()
        local entry = action_state.get_selected_entry()
        if not entry then
          return
        end
        actions.close(prompt_bufnr)
        vim.schedule(function()
          prompt_send(entry.value)
        end)
      end
      map("i", "<C-s>", send_selected)
      map("n", "<C-s>", send_selected)
      return true
    end,
  }):find()
end

function M.setup(opts)
  opts = opts or {}
  vim.schedule(ensure_state_dir)
  local agents = opts.agents or AGENTS
  vim.api.nvim_create_user_command("Herd", function()
    M.pick(agents)
  end, { desc = "Overview of LLM/agent sessions" })
  if opts.key ~= false then
    vim.keymap.set("n", opts.key or "<leader>ah", function()
      M.pick(agents)
    end, { desc = "Agent herd overview" })
  end
end

return M
