return {
  {
    "kndndrj/nvim-dbee",
    enable = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup(--[[optional config]])
    end,
    keys = {
      {
        "<leader>db",
        function()
          require("dbee").toggle()
        end,
      },
    },
  },
}
