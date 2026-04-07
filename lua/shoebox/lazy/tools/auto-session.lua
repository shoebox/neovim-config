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
    },
  },
}
