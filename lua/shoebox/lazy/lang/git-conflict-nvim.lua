return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = true,
    lazy = true,
    init = function()
      vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function(args)
          local found = vim.fn.search("^<<<<<<<", "nw", 0, 100)
          if found > 0 then
            require("lazy").load({ plugins = { "git-conflict.nvim" } })
            vim.api.nvim_exec_autocmds("BufReadPost", { buffer = args.buf })
            return true
          end
        end,
      })
    end,
  },
}
