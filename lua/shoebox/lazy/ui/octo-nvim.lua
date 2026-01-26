return {
  {
    "pwntester/octo.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "Octo" },
    config = function()
      require("octo").setup({
        github_hostname = "github.com",
        ssh_aliases = { ["nbcugithub.com"] = "github.com" },
      })
    end,
  },
}
