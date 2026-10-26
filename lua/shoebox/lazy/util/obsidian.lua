return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    opts = {
      -- render-markdown owns conceals; obsidian UI conflicts with it.
      ui = { enable = false },
      legacy_commands = false,
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
    cmd = { "Obsidian" },
  },
}
