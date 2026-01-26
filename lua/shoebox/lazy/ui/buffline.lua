return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        diagnostics = false,
        mode = "tabs",
        numbers = "ordinal",
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
          },
        },
        separator_style = "slope",
        show_buffer_close_icons = false,
        show_buffer_icons = false,
        themable = true,
        highlights = {
          fill = {
            bg = {
              attribute = "bg",
              highlight = "Pmenu",
            },
          },
        },
      },
    },
    keys = {
      { "<space>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Bufferline - Go to buffer 1" },
      { "<space>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Bufferline - Go to buffer 2" },
      { "<space>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Bufferline - Go to buffer 3" },
      { "<space>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Bufferline - Go to buffer 4" },
      { "<space>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Bufferline - Go to buffer 5" },
      { "<space>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Bufferline - Go to buffer 6" },
      { "<space>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Bufferline - Go to buffer 7" },
      { "<space>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Bufferline - Go to buffer 8" },
      { "<space>9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Bufferline - Go to buffer 9" },
    },
    event = "BufEnter",
  },
}
