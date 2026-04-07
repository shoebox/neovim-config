function _G.set_terminal_keymaps()
  print("set terminal keymap")
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<space><left>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<space><right>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<space><up>", [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set("t", "<space><down>", [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
-- vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

return {
  {
    "akinsho/toggleterm.nvim",
    init = function()
      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
      -- vim.api.nvim_create_user_command("TermOpen", function()
      --   set_terminal_keymaps()
      -- end, { desc = "Sets wincmd to term windows" })
    end,
    opts = {
      direction = "float",
      hide_numbers = true,
      float_opts = {
        width = function()
          return math.floor(vim.o.columns)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.9)
        end,
      },
      size = 100,
      winbar = {
        enabled = true,
        name_formatter = function(term)
          return term.name
        end,
      },
    },
    cmd = {
      "ToggleTerm",
      "TermExec",
      "ToggleTermSendCurrentLine",
      "ToggleTermSendVisualLines",
      "ToggleTermSendVisualSelection",
      "ToggleTermOpenAll",
      "ToggleTermCloseAll",
      "ToggleTermToggleAll",
    },
    keys = {
      {
        "<F8>",
        function()
          vim.cmd("lua require('toggleterm').toggle(1, nil, nil, 'float')")
          -- vim.cmd("redraw!")
        end,
        desc = "Toggle Floating Terminal",
        mode = { "n", "t" },
      },
      {
        "<F7>",
        function()
          vim.cmd("lua require('toggleterm').toggle(2, nil, nil, 'vertical')")
          -- vim.cmd("redraw!")
        end,
        desc = "Toggle Split Terminal",
        mode = { "n", "t" },
      },
    },
  },
  -- {
  --   "voldikss/vim-floaterm",
  --   cmd = {
  --     "FloatermNew",
  --     "FloatermToggle",
  --   },
  --   init = function()
  --     vim.g.floaterm_shell = "zsh"
  --     vim.g.floaterm_keymap_toggle = "<F7>"
  --     vim.g.floaterm_width = 0.99999
  --     vim.g.floaterm_height = 0.99999
  --
  --     vim.api.nvim_create_autocmd("VimResized", {
  --       pattern = "*",
  --       command = "FloatermUpdate",
  --     })
  --   end,
  --   keys = {
  --     {
  --       "<F7>",
  --       "<cmd>FloatermToggle<cr>",
  --       desc = "Toggle FloatTerm",
  --       mode = { "n", "t" },
  --     },
  --     {
  --       "<F8>",
  --       "<cmd>FloatermNext<cr>",
  --       desc = "Next FloatTerm",
  --       mode = { "n", "t" },
  --     },
  --     {
  --       "<F9>",
  --       "<cmd>FloatermPrev<cr>",
  --       desc = "Prev FloatTerm",
  --       mode = { "n", "t" },
  --     },
  --     {
  --       "<F10>",
  --       "<cmd>FloatermPrev<cr>",
  --       desc = "Close FloatTerm",
  --       mode = { "n", "t" },
  --     },
  --     {
  --       "<leader>ftk",
  --       "<cmd>FloatermKil<cr>",
  --       desc = "Kill FloatTerm",
  --       mode = { "n", "t" },
  --     },
  --     {
  --       "<leader>ftl",
  --       "<cmd>FloatermLast<cr>",
  --       desc = "Last FloatTerm",
  --       mode = { "n", "t" },
  --     },
  --     {
  --       "<F7>",
  --       "<cmd><C-\\><C-n>:FloatermToggle<cr>",
  --       desc = "Toggle FloatTerm",
  --       mode = { "n", "t" },
  --     },
  --   },
  -- },
}
