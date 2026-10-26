local bind = require("shoebox.mapping.helper")
local vim = vim or {}
local map_cmd = bind.map_cmd

local global_nav = {
  ["n|<space><Left>"] = map_cmd("<C-W>h"),
  ["v|<space><Left>"] = map_cmd("<C-W>h"),
  ["n|<space><Right>"] = map_cmd("<C-W>l"),
  ["v|<space><Right>"] = map_cmd("<C-W>l"),
  ["n|<space><Up>"] = map_cmd("<C-W>k"),
  ["v|<space><Up>"] = map_cmd("<C-W>k"),
  ["n|<space><Down>"] = map_cmd("<C-W>j"),
  ["v|<space><Down>"] = map_cmd("<C-W>j"),
}

vim.keymap.set({ "n", "x" }, "<c-s>", "<cmd>w<CR>")

local clipboard = function()
  local opts = { noremap = true, silent = true }
  local function notify_copy()
    vim.notify("Copied to clipboard!", vim.log.levels.INFO, { title = "Clipboard" })
  end
  vim.keymap.set("v", "<leader>c", function()
    vim.cmd('normal! "+y')
    notify_copy()
  end, opts)
  vim.keymap.set("i", "<leader>c", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-o>"+y', true, false, true), "n", true)
    notify_copy()
  end, opts)
  vim.keymap.set("n", "<leader>c", function()
    vim.cmd('normal! "+y')
    notify_copy()
  end, opts)
end

bind.nvim_load_mapping(global_nav)

local git = function()
  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "gga", function()
    vim.cmd("Git add %")
    vim.notify("Added file to git staging area!", vim.log.levels.INFO, { title = "Git" })
  end, opts)
  vim.keymap.set("n", "ggc", function()
    vim.cmd("Git commit")
  end, opts)
end

vim.keymap.set("n", "<leader>gs", function()
  for _, executable in ipairs({ "git", "diffnav", "delta", "bash" }) do
    if vim.fn.executable(executable) ~= 1 then
      vim.notify(executable .. " is required for diffnav", vim.log.levels.ERROR)
      return
    end
  end
  local cwd = vim.fn.getcwd()
  vim.system({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Cannot find git repository: " .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end
      local root = vim.trim(result.stdout)
      vim.system(
        { "git", "status", "--porcelain", "--untracked-files=all" },
        { cwd = root, text = true },
        function(status)
          vim.schedule(function()
            if status.code ~= 0 then
              vim.notify("Cannot read git status: " .. (status.stderr or ""), vim.log.levels.ERROR)
              return
            elseif vim.trim(status.stdout) == "" then
              vim.notify("No uncommitted changes", vim.log.levels.INFO)
              return
            end
            -- Delta colors live in delta/eldritch.gitconfig (included from ~/.gitconfig).
            local colors = require("eldritch.colors").setup()
            -- diffnav runs the watch command through `sh -c`, so escape it twice.
            local watch_cmd =
              vim.fn.shellescape(vim.fn.stdpath("config") .. "/scripts/diffnav-diff")
            local terminal = require("toggleterm.terminal").Terminal:new({
              cmd = "diffnav --watch --watch-cmd " .. vim.fn.shellescape(watch_cmd),
              dir = root,
              direction = "float",
              float_opts = {
                border = "none",
                row = 0,
                col = 0,
                width = function()
                  return vim.o.columns
                end,
                height = function()
                  return math.max(1, vim.o.lines - vim.o.cmdheight)
                end,
                winblend = 0,
              },
              highlights = {
                Normal = { guifg = colors.fg, guibg = colors.bg },
                NormalFloat = { guifg = colors.fg, guibg = colors.bg },
              },
              env = {
                EDITOR = vim.fn.stdpath("config") .. "/scripts/diffnav-open",
                NVIM = vim.v.servername,
              },
              close_on_exit = false,
              on_open = function(term)
                -- diffnav only binds ctrl+d/ctrl+u for paging
                vim.keymap.set("t", "<PageDown>", "<C-d>", { buffer = term.bufnr })
                vim.keymap.set("t", "<PageUp>", "<C-u>", { buffer = term.bufnr })
              end,
              on_exit = function(term, _, code)
                vim.schedule(function()
                  if code == 0 then
                    term:close()
                  else
                    vim.notify("Diffnav exited with code " .. code, vim.log.levels.ERROR)
                  end
                end)
              end,
            })
            terminal.env.DIFFNAV_TERM_ID = tostring(terminal.id)
            terminal:toggle()
          end)
        end
      )
    end)
  end)
end, { desc = "Diffnav: uncommitted changes" })

-- Sound word with quotes...
vim.keymap.set("n", "<leader>wsq", 'ciw""<Esc>P', { desc = "Surround word with quotes" })
vim.keymap.set("n", "<leader>wss", "ciw``<Esc>P", { desc = "Surround word with quotes" })

-- Unwrap hard-wrapped prose (fold soft-wrapped lines back into one line per block).
-- Markdown-aware: keeps list items / blockquotes / headings / tables / code fences on
-- their own lines, only folding true continuation lines (a wrapped bullet stays one bullet).
local function md_block_start(line)
  return line:match("^%s*$") -- blank
    or line:match("^%s*[-*+]%s") -- unordered list item
    or line:match("^%s*%d+[.)]%s") -- ordered list item
    or line:match("^%s*>") -- blockquote
    or line:match("^%s*#") -- heading
    or line:match("^%s*|") -- table row
end

local function unwrap_range(s, e)
  if s < 1 or e < s then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
  local out, in_code = {}, false
  for _, line in ipairs(lines) do
    local fence = line:match("^%s*```") or line:match("^%s*~~~")
    if in_code or fence or #out == 0 or md_block_start(line) then
      out[#out + 1] = (line:gsub("%s+$", ""))
    else
      out[#out] = out[#out]:gsub("%s+$", "") .. " " .. line:gsub("^%s+", ""):gsub("%s+$", "")
    end
    if fence then
      in_code = not in_code
    end
  end
  vim.api.nvim_buf_set_lines(0, s - 1, e, false, out)
end

-- operatorfunc + g@ makes the paragraph map dot-repeatable natively (no vim-repeat needed).
function _G.ShoeboxUnwrapOp()
  unwrap_range(vim.fn.line("'["), vim.fn.line("']"))
end
vim.keymap.set("n", "<leader>mw", function()
  vim.o.operatorfunc = "v:lua.ShoeboxUnwrapOp"
  return "g@ip"
end, { expr = true, desc = "Unwrap paragraph to one line (dot-repeatable)" })
vim.keymap.set(
  "x",
  "<leader>mw",
  ":<C-u>lua ShoeboxUnwrapVisual()<CR>",
  { desc = "Unwrap selection" }
)

function _G.ShoeboxUnwrapVisual()
  unwrap_range(vim.fn.line("'<"), vim.fn.line("'>"))
end

vim.api.nvim_create_user_command("UnwrapAll", function()
  unwrap_range(1, vim.fn.line("$"))
end, { desc = "Unwrap all blocks (markdown-aware)" })

clipboard()
git()
