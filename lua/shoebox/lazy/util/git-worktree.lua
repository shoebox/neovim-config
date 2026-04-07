return {
  {
    "ThePrimeagen/git-worktree.nvim",
    config = function()
      local Worktree = require("git-worktree")

      Worktree.on_tree_change(function(op, metadata)
        if op == Worktree.Operations.Switch then
          -- Save current session before switching
          vim.cmd("SessionSave")

          -- After switching, restore session for the new worktree (if it exists)
          vim.defer_fn(function()
            vim.cmd("SessionRestore")
          end, 100)
        end
      end)
    end,
    keys = {
      {
        "<leader>wt",
        function()
          require("telescope").load_extension("git_worktree")
          require("telescope").extensions.git_worktree.git_worktrees()
        end,
        desc = "Git Worktrees",
      },
    },
  },
}
