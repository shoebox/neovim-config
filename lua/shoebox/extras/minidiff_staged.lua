-- Wraps mini.diff's git source: unstaged changes keep mini.diff's signs (buffer vs
-- index) and staged-only lines (differ from HEAD, not in an unstaged hunk)
-- get dashed signs in the same colors. The HEAD blob is re-read only when HEAD moves.
local M = {}

local ns = vim.api.nvim_create_namespace("shoebox_minidiff_staged")
local group = vim.api.nvim_create_augroup("ShoeboxMiniDiffStaged", { clear = true })
local state = {}

local function git(args, cwd, on_done)
  vim.system(
    vim.list_extend({ "git" }, args),
    { cwd = cwd, text = true },
    vim.schedule_wrap(on_done)
  )
end

local function render(buf)
  local s = state[buf]
  if not (s and s.head and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local data = MiniDiff.get_buf_data(buf)
  local unstaged = {}
  for _, h in ipairs(data and data.hunks or {}) do
    for l = h.buf_start, h.buf_start + h.buf_count - 1 do
      unstaged[l] = true
    end
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local diff = vim.text.diff(s.head, table.concat(lines, "\n") .. "\n", {
    result_type = "indices",
    algorithm = "histogram",
    indent_heuristic = true,
  })
  local function mark(l, text, hl)
    if not unstaged[l] and l <= #lines then
      vim.api.nvim_buf_set_extmark(
        buf,
        ns,
        l - 1,
        0,
        { sign_text = text, sign_hl_group = hl, priority = 199 }
      )
    end
  end
  for _, d in ipairs(diff) do
    local a_count, b_start, b_count = d[2], d[3], d[4]
    if b_count == 0 then
      mark(math.max(b_start, 1), "▁", "MiniDiffSignDelete")
    end
    for l = b_start, b_start + b_count - 1 do
      mark(l, "┆", a_count == 0 and "MiniDiffSignAdd" or "MiniDiffSignChange")
    end
  end
end

local function refresh_head(buf)
  local s = state[buf]
  if not s then
    return
  end
  s.token = s.token + 1
  local token = s.token
  local function alive()
    return state[buf] == s and s.token == token
  end
  git({ "rev-parse", "-q", "--verify", "HEAD" }, s.dir, function(head)
    local commit = head.code == 0 and vim.trim(head.stdout) or "unborn"
    if not alive() or commit == s.commit then
      return
    end
    local function set(text)
      s.commit, s.head = commit, text
      render(buf)
    end
    if commit == "unborn" then
      return set("")
    end
    git({ "cat-file", "blob", commit .. ":./" .. s.name }, s.dir, function(blob)
      if alive() then
        -- Not in HEAD (new file): every line is an addition.
        set(blob.code == 0 and blob.stdout:gsub("\r\n", "\n") or "")
      end
    end)
  end)
end

local function stop(buf)
  local s = state[buf]
  state[buf] = nil
  if s then
    s.watcher:close()
    s.timer:close()
  end
  pcall(vim.api.nvim_clear_autocmds, { group = group, buffer = buf })
  pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
end

local function start(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  local dir = vim.fs.dirname(path)
  git({ "rev-parse", "--path-format=absolute", "--git-dir" }, dir, function(res)
    if res.code ~= 0 or not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    stop(buf)
    local s = {
      dir = dir,
      name = vim.fs.basename(path),
      token = 0,
      timer = vim.uv.new_timer(),
      watcher = vim.uv.new_fs_event(),
    }
    state[buf] = s
    -- Commits, resets and checkouts touch files directly inside the git dir.
    s.watcher:start(vim.trim(res.stdout), {}, function()
      s.timer:stop()
      s.timer:start(
        50,
        0,
        vim.schedule_wrap(function()
          refresh_head(buf)
        end)
      )
    end)
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
      group = group,
      buffer = buf,
      callback = function()
        refresh_head(buf)
      end,
    })
    refresh_head(buf)
  end)
end

-- mini.diff fires this inside nvim_buf_call, so the current buffer is the updated one.
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("ShoeboxMiniDiffStagedRender", { clear = true }),
  pattern = "MiniDiffUpdated",
  callback = function()
    render(vim.api.nvim_get_current_buf())
  end,
})

M.source = function()
  local src = require("mini.diff").gen_source.git()
  return {
    name = src.name,
    apply_hunks = src.apply_hunks,
    attach = function(buf)
      local res = src.attach(buf)
      if res ~= false then
        start(buf)
      end
      return res
    end,
    detach = function(buf)
      stop(buf)
      src.detach(buf)
    end,
  }
end

return M
