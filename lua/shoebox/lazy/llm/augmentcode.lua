local vim = vim or {}
vim.cmd([[
let g:augment_disable_tab_mapping = v:true
let g:augment_disable_completions = v:true
]])

return {
  {
    "augmentcode/augment.vim",
    cmd = { "Augment" },
    enabled = false,
    config = function()
      vim.g.augment_workspace_folders = { vim.fn.getcwd() }
    end,
  },
}
