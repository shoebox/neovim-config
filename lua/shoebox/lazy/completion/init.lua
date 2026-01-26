local vim = vim

return {
  {
    "saghen/blink.cmp",
    event = { "InsertEnter" },
    version = "*",
    opts = {
      enabled = function()
        return vim.bo.buftype ~= "prompt" and vim.bo.buftype ~= "nofile"
      end,
      keymap = {
        preset = "default",
        ["<Tab>"] = {},
        ["<CR>"] = { "accept", "fallback" },
      },
      fuzzy = {
        sorts = {
          "exact",
          -- defaults
          "score",
          "sort_text",
        },
        implementation = "prefer_rust_with_warning",
      },
      signature = {
        enabled = true,
        trigger = {
          enabled = true,
        },
      },
      completion = {
        ghost_text = {
          enabled = false,
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 100,
          window = {
            border = "none",
          },
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
        menu = {
          auto_show = true,
          draw = {
            -- We don't need label_description now because label and label_description are already
            -- combined together in label by colorful-menu.nvim.
            columns = { { "kind_icon" }, { "label", gap = 1 } },
            padding = { 1, 2 },
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon .. ctx.icon_gap
                end,
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              label = {
                width = { fill = true, max = 100 },
                text = function(ctx)
                  local highlights_info = require("colorful-menu").blink_highlights(ctx)
                  if highlights_info ~= nil then
                    -- Or you want to add more item to label
                    return highlights_info.label
                  else
                    return ctx.label
                  end
                end,
                highlight = function(ctx)
                  local highlights = {}
                  local highlights_info = require("colorful-menu").blink_highlights(ctx)
                  if highlights_info ~= nil then
                    highlights = highlights_info.highlights
                  end
                  for _, idx in ipairs(ctx.label_matched_indices) do
                    table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                  end
                  -- Do something else
                  return highlights
                end,
              },
            },
          },
        },
      },
      cmdline = {
        sources = {},
        enabled = false,
      },
      term = {
        sources = {},
        enabled = false,
      },
      sources = {
        default = {
          "buffer",
          "lsp",
          "omni",
          "path",
          "snippets",
          "copilot",
        },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
          cmdline = {
            enabled = false,
          },
        },
      },
    },
    dependencies = {
      { "fang2hou/blink-copilot", lazy = true },
      { "xzbdmw/colorful-menu.nvim", lazy = true },
    },
  },
}
