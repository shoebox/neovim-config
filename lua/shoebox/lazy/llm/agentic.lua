local _fidget_handles = {}

return {
  {
    "carlos-algms/agentic.nvim",
    opts = {
      provider = "auggie-acp",
      headers = {
        chat = function(parts)
          local header = parts.title
          if parts.context then
            header = header .. " [" .. parts.context .. "]"
          end
          if parts.suffix then
            header = header .. " • " .. parts.suffix
          end
          return header
        end,
      },
      hooks = {
        on_prompt_submit = function(data)
          local has_fidget, fidget = pcall(require, "fidget")
          if not has_fidget then
            return
          end

          -- Cancel any existing handle for this session
          if _fidget_handles[data.session_id] then
            _fidget_handles[data.session_id]:cancel()
          end

          local short_prompt = data.prompt and data.prompt:sub(1, 50) or ""
          if data.prompt and #data.prompt > 50 then
            short_prompt = short_prompt .. "…"
          end

          _fidget_handles[data.session_id] = fidget.progress.handle.create({
            title = short_prompt,
            message = "Thinking...",
            lsp_client = { name = "Agentic" },
          })
        end,
        on_response_complete = function(data)
          local handle = _fidget_handles[data.session_id]
          if handle then
            handle.message = data.success and "Done." or "Error."
            handle:finish()
            _fidget_handles[data.session_id] = nil
          end
        end,
      },
    },

    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "AgenticChat", "AgenticInput", "AgenticFiles" },
        callback = function(ev)
          vim.keymap.set("n", "<Esc>", function()
            require("agentic").stop_generation()
          end, { buffer = ev.buf, desc = "Stop Agentic generation" })
        end,
      })
    end,

    -- these are just suggested keymaps; customize as desired
    keys = {
      {
        "<C-\\>",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v", "i" },
        desc = "Toggle Agentic Chat",
      },
      {
        "<C-'>",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Add file or selection to Agentic to Context",
      },
      {
        "<C-,>",
        function()
          require("agentic").new_session()
        end,
        mode = { "n", "v", "i" },
        desc = "New Agentic Session",
      },
      {
        "<leader>air", -- ai Restore
        function()
          require("agentic").restore_session()
        end,
        desc = "Agentic Restore session",
        silent = true,
        mode = { "n", "v", "i" },
      },
      {
        "<leader>ad", -- ai Diagnostics
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        desc = "Add current line diagnostic to Agentic",
        mode = { "n" },
      },
      {
        "<leader>aD", -- ai all Diagnostics
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        desc = "Add all buffer diagnostics to Agentic",
        mode = { "n" },
      },
    },
  },
}
