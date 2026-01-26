return {
  {
    "voldikss/vim-floaterm",
    cmd = { "FloatermToggle", "FloatermNew" },
    init = function()
      vim.g.floaterm_shell = "zsh"
      vim.g.floaterm_keymap_toggle = "<F7>"
      vim.g.floaterm_width = 0.9
      vim.g.floaterm_height = 0.9
    end,
    keys = {
      {
        "<F7>",
        "<cmd>FloatermToggle",
        desc = "Toggle FloatTern",
        mode = { "n" },
      },
      {
        "<F7>",
        "<cmd><C-\\><C-n>:FloatermToggle",
        desc = "Toggle FloatTern",
        mode = { "t" },
      },
    },
  },
}
