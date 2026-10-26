return {
  {
    "rmagatti/auto-session",
    cmd = {
      "SessionSave",
      "SessionRestore",
      "SessionDelete",
      "SessionDisableAutoSave",
      "SessionToggleAutoSave",
      "SessionPurgeOrphaned",
      "SessionSearch",
      "Autosession",
    },
    lazy = false,
    opts = {
      auto_restore = true,
      auto_create = true,
      git_use_branch_name = true,
      show_auto_restore_notif = true,
      session_lens = {
        load_on_setup = false,
      },
      -- Drop restored buffers whose file was deleted since the session was saved,
      -- so neo-tree's follow_current_file doesn't try to reveal a dead path (ENOENT).
      post_restore_cmds = {
        function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(buf)
            -- ponytail: only touch plain, named, on-disk file buffers; skip terminals,
            -- neo-tree, scratch, and dirs. Modified buffers are left alone (force=false).
            if
              name ~= ""
              and vim.bo[buf].buftype == ""
              and vim.fn.isdirectory(name) == 0
              and vim.fn.filereadable(name) == 0
            then
              pcall(vim.api.nvim_buf_delete, buf, { force = false })
            end
          end
        end,
      },
    },
  },
}
