return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    ft = {
      "md",
      "markdown",
      "Avante",
      "codecompanion",
      -- "AgenticChat",
      "AgenticInput",
    },
    opts = {
      file_types = { "asciidoc", "md", "markdown", "Avante", "codecompanion", "AgenticInput" },
      on = {
        attach = function(data)
          if vim.b[data.buf].agentic_render_md_paused then
            vim.b[data.buf].agentic_render_md_enabled = require("render-markdown.state").get(data.buf).enabled
            require("render-markdown.core.manager").set_buf(data.buf, false)
          end
        end,
      },
      bullet = {
        left_pad = 2,
        right_pad = 1,
      },
      checkbox = {
        left_pad = 2,
      },
      heading = {
        border = true,
        right_pad = 1,
      },
      overrides = {
        filetype = {
          -- Streaming chat: viewport-only (±10 lines), fewer handlers, long debounce.
          -- agentic.lua pauses rendering from prompt submit through completion.
          AgenticChat = {
            debounce = 1200,
            render_modes = { "n" },
            anti_conceal = { enabled = false },
            heading = { border = false, sign = false },
            pipe_table = { enabled = false },
            latex = { enabled = false },
            html = { enabled = false },
            indent = { enabled = false },
            sign = { enabled = false },
            dash = { enabled = false },
            callout = {},
          },
          AgenticInput = {
            enabled = false,
          },
        },
      },
    },
    -- ft lazy-load runs after FileType; attach the buffer that triggered load.
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.schedule(function()
        local buf = vim.api.nvim_get_current_buf()
        local manager = require("render-markdown.core.manager")
        local fts = require("render-markdown.state").file_types
        if
          vim.api.nvim_buf_is_valid(buf)
          and not manager.attached(buf)
          and vim.tbl_contains(fts, vim.bo[buf].filetype)
        then
          manager.attach(buf)
        end
      end)
    end,
  },
}
