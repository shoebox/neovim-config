return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    requires = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      daily_notes = {
        folder = "notes/dailies",
      },
      workspaces = {
        {
          name = "johannsky",
          path = "~/Desktop/obsidian/johannsky/",
        },
      },
    },
    cmd = {
      "ObsidianBacklinks",
      "ObsidianDailies",
      "ObsidianExtractNote",
      "ObsidianFollowLink",
      "ObsidianLink",
      "ObsidianLinkNew",
      "ObsidianLinks",
      "ObsidianNewFromTemplate",
      "ObsidianOpen",
      "ObsidianPasteImg",
      "ObsidianQuickSwitch",
      "ObsidianRename",
      "ObsidianSearch",
      "ObsidianTOC",
      "ObsidianTags",
      "ObsidianTemplate",
      "ObsidianToggleCheckbox",
      "ObsidianWorkspace",
      "ObsidianNew",
      "ObsidianToday",
      "ObsidianTomorrow",
      "ObsidianYesterday",
    },
  },
}
