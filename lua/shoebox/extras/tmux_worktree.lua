-- Quick plugin: open/close a tmux window for a given git worktree branch.
-- Each git worktree gets its own tmux window (named after the branch) rooted
-- at the worktree path, so jumping between branches is a single keystroke.

local vim = vim

local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Tmux Worktree" })
end

-- Run a command (list form, no shell) and return its stdout lines on success.
local function run(cmd)
  local out = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return nil, table.concat(out, "\n")
  end
  return out
end

local function in_tmux()
  return (vim.env.TMUX or "") ~= ""
end

-- Parse `git worktree list --porcelain` into { { path = , branch = }, ... }.
function M.worktrees()
  local lines, err = run({ "git", "worktree", "list", "--porcelain" })
  if not lines then
    return nil, err
  end

  local list = {}
  local current
  for _, line in ipairs(lines) do
    local path = line:match("^worktree (.+)$")
    local branch = line:match("^branch (.+)$")
    if path then
      current = { path = path }
      table.insert(list, current)
    elseif branch and current then
      current.branch = branch:gsub("^refs/heads/", "")
    end
  end
  return list
end

-- tmux window names must be safe to use as a `-t` target, so collapse any
-- character outside [A-Za-z0-9._-] (e.g. the "/" in "feature/foo") to a dash.
local function window_name(worktree)
  local label = worktree.branch or vim.fn.fnamemodify(worktree.path, ":t")
  return (label:gsub("[^%w._-]", "-"))
end

local function window_exists(name)
  local windows = run({ "tmux", "list-windows", "-F", "#{window_name}" })
  if not windows then
    return false
  end
  for _, win in ipairs(windows) do
    if win == name then
      return true
    end
  end
  return false
end

-- Open (or focus, if it already exists) the tmux window for a worktree.
function M.open(worktree)
  if not in_tmux() then
    notify("Not inside a tmux session", vim.log.levels.WARN)
    return
  end

  local name = window_name(worktree)
  if window_exists(name) then
    run({ "tmux", "select-window", "-t", name })
    notify("Focused tmux window: " .. name)
    return
  end

  local _, err = run({ "tmux", "new-window", "-n", name, "-c", worktree.path })
  if err then
    notify("Failed to open window: " .. err, vim.log.levels.ERROR)
    return
  end
  notify("Opened tmux window: " .. name)
end

-- Close the tmux window for a worktree, if one exists.
function M.close(worktree)
  if not in_tmux() then
    notify("Not inside a tmux session", vim.log.levels.WARN)
    return
  end

  local name = window_name(worktree)
  if not window_exists(name) then
    notify("No tmux window for: " .. name, vim.log.levels.WARN)
    return
  end

  local _, err = run({ "tmux", "kill-window", "-t", name })
  if err then
    notify("Failed to close window: " .. err, vim.log.levels.ERROR)
    return
  end
  notify("Closed tmux window: " .. name)
end

-- Open the window if it is closed, close it if it is open.
function M.toggle(worktree)
  if window_exists(window_name(worktree)) then
    M.close(worktree)
  else
    M.open(worktree)
  end
end

-- Prompt for a worktree, then run the given action ("toggle"/"open"/"close").
function M.pick(action)
  local list, err = M.worktrees()
  if not list then
    notify("git worktree list failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
    return
  end
  if #list == 0 then
    notify("No git worktrees found", vim.log.levels.WARN)
    return
  end

  vim.ui.select(list, {
    prompt = "Tmux worktree window:",
    format_item = function(worktree)
      return (worktree.branch or "(detached)") .. "  →  " .. worktree.path
    end,
  }, function(choice)
    if choice then
      (M[action] or M.toggle)(choice)
    end
  end)
end

function M.setup(opts)
  opts = opts or {}

  vim.api.nvim_create_user_command("TmuxWorktree", function()
    M.pick("toggle")
  end, { desc = "Toggle a tmux window for a git worktree" })

  vim.api.nvim_create_user_command("TmuxWorktreeOpen", function()
    M.pick("open")
  end, { desc = "Open a tmux window for a git worktree" })

  vim.api.nvim_create_user_command("TmuxWorktreeClose", function()
    M.pick("close")
  end, { desc = "Close a tmux window for a git worktree" })

  vim.keymap.set("n", opts.key or "<leader>wT", function()
    M.pick("toggle")
  end, { desc = "Tmux worktree window (toggle)" })
end

return M
