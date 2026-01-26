return {
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
    config = function()
      local highlight = {
        "VertSplit",
      }

      require("ibl").setup({
        indent = { highlight = highlight },
        scope = { enabled = false },
        whitespace = {
          remove_blankline_trail = false,
        },
      })
    end,
    event = { "BufRead", "BufNewFile" },
  },
}
