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

-- Sound word with quotes...
vim.keymap.set("n", "<leader>wsq", 'ciw""<Esc>P', { desc = "Surround word with quotes" })
vim.keymap.set("n", "<leader>wss", "ciw``<Esc>P", { desc = "Surround word with quotes" })

clipboard()
git()
