return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    ft = "asciidoc",
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
      "ObsidianNew",
      "ObsidianToday",
      "ObsidianYesterday",
      "ObsidianTomorrow",
    },
  },
}
