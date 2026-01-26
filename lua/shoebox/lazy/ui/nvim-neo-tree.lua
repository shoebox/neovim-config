local vim = vim

local function copy_path(state)
  local node = state.tree:get_node()
  local filepath = node:get_id()
  local filename = node.name
  local modify = vim.fn.fnamemodify

  local results = {
    filepath,
    modify(filepath, ":."),
    modify(filepath, ":~"),
    filename,
    modify(filename, ":r"),
    modify(filename, ":e"),
  }

  vim.ui.select({
    "1. Absolute path: " .. results[1],
    "2. Path relative to CWD: " .. results[2],
    "3. Path relative to HOME: " .. results[3],
    "4. Filename: " .. results[4],
    "5. Filename without extension: " .. results[5],
    "6. Extension of the filename: " .. results[6],
  }, { prompt = "Choose to copy to clipboard:" }, function(choice)
    if choice then
      local i = tonumber(choice:sub(1, 1))
      if i then
        local result = results[i]
        vim.fn.setreg('"', result)
        vim.fn.setreg("+", result)

        vim.notify("Copied: " .. result)
      else
        vim.notify("Invalid selection")
      end
    else
      vim.notify("Selection cancelled")
    end
  end)
end

local git_available = vim.fn.executable("git") == 1

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    config = function()
      require("neo-tree").setup({
        default_component_configs = {
          indent = {
            indent_size = 2,
            padding = 0, -- extra padding on left hand side
          },
        },
        close_if_last_window = true,
        auto_clean_after_session_restore = false,
        event_handlers = {
          {
            event = "file_opened",
            handler = function(file_path)
              require("neo-tree.command").execute({ action = "close" })
            end,
          },
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          filtered_items = {
            hide_gitignored = git_available,
            never_show = {
              ".DS_Store",
              "thumbs.db",
            },
          },
        },
        renderers = {
          directory = {
            { "indent" },
            { "icon" },
            { "current_filter" },
            {
              "container",
              content = {
                { "name", zindex = 10 },
                {
                  "symlink_target",
                  zindex = 10,
                  highlight = "NeoTreeSymbolicLinkTarget",
                },
                { "clipboard", zindex = 10 },
                {
                  "diagnostics",
                  errors_only = true,
                  zindex = 20,
                  align = "right",
                  hide_when_expanded = true,
                },
                { "git_status", zindex = 10, align = "right", hide_when_expanded = true },
                -- { "file_size", zindex = 10, align = "right" },
                -- { "type", zindex = 10, align = "right" },
                -- { "last_modified", zindex = 10, align = "right" },
                -- { "created", zindex = 10, align = "right" },
              },
            },
          },
          root = {
            {
              "current_path",
              highlight = "NeoTreeCurrentPathBold",
            },
          },
        },
        window = {
          mappings = {
            ["<cr>"] = "open_with_window_picker",
            ["<c-t>"] = "open_tabnew",
            ["Y"] = copy_path,
            ["ga"] = "git_add_file",
          },
          width = 30,
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "s1n7ax/nvim-window-picker",
    },
    keys = {
      {
        "<space>n",
        function()
          vim.cmd("Neotree toggle")
        end,
        desc = "Nvim-tree - toggle",
      },
    },
  },
}
