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
      session_lens = {
        load_on_setup = false,
      },
    },
  },
}
