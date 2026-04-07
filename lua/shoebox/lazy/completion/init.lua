local vim = vim

local function setup_completeopt()
  vim.opt.completeopt = { "menuone", "popup", "fuzzy", "noinsert" }
end

local function is_completion_disabled()
  local buftype = vim.bo.buftype
  return buftype == "prompt" or buftype == "nofile"
end

local function trigger_lsp_completion()
  vim.lsp.completion.get()
end

local function trigger_buffer_completion()
  local key = vim.keycode("<C-x><C-n>")
  vim.api.nvim_feedkeys(key, "m", false)
end

local function on_insert_char_pre()
  if is_completion_disabled() then
    return
  end

  vim.schedule(function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })

    if next(clients) ~= nil then
      trigger_lsp_completion()
    else
      trigger_buffer_completion()
    end
  end)
end

local function setup_auto_completion()
  vim.api.nvim_create_autocmd("InsertCharPre", {
    callback = on_insert_char_pre,
  })
end

local function setup_tab_keymap()
  vim.keymap.set("i", "<tab>", function()
    local key = vim.keycode("<tab>")
    if vim.fn.pumvisible() == 1 then
      key = vim.keycode("<C-n>")
    end
    vim.api.nvim_feedkeys(key, "n", false)
  end, {})
end

local function setup_enter_keymap()
  vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then
      return vim.keycode("<C-y>")
    end
    return vim.keycode("<CR>")
  end, { expr = true })
end

local function setup_keymaps()
  setup_tab_keymap()
  setup_enter_keymap()
end

local function convert_completion_item(item)
  local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or "Text"
  return {
    abbr = item.label,
    kind = kind,
  }
end

local function setup_lsp_completion()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
        autotrigger = false,
        convert = convert_completion_item,
      })
    end,
  })
end

local function setup()
  setup_completeopt()
  setup_auto_completion()
  setup_keymaps()
  setup_lsp_completion()
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = setup,
})

return {
  {
    "onsails/lspkind.nvim",
    opts = {
      mode = "symbol_text",
    },
    event = "InsertEnter",
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      bind = true,
      handler_opts = { border = "rounded" },
      max_height = 20,
      max_width = 80,
      wrap = true,
      floating_window = true,
      floating_window_above_cur_line = true,
      doc_lines = 20,
      hint_enable = false,
    },
  },
}
