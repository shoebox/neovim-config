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
        auto_clean_after_session_restore = true, -- drop broken neo-tree buffers restored from a session
        event_handlers = {
          {
            event = "file_opened",
            handler = function(file_path)
              require("neo-tree.command").execute({ action = "close" })
            end,
          },
        },
        enable_git_status = true,
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
                { "git_status", zindex = 10, align = "right", hide_when_expanded = false },
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

      -- ponytail: follow_current_file has no on-disk existence check, so on session
      -- restore it reveals deleted buffers and scans their now-missing parent dirs,
      -- spamming [Neo-tree ERROR] ... ENOENT. Skip follow when the current buffer's
      -- path no longer exists. Ceiling: depends on the internal filesystem source's
      -- `follow`; pcall-guarded so a neo-tree API change degrades to the old noisy
      -- behaviour instead of erroring out.
      local ok_fs, fs = pcall(require, "neo-tree.sources.filesystem")
      if ok_fs and type(fs.follow) == "function" then
        local follow = fs.follow
        fs.follow = function(...)
          local name = vim.api.nvim_buf_get_name(0)
          if name ~= "" and vim.fn.filereadable(name) == 0 and vim.fn.isdirectory(name) == 0 then
            return false
          end
          return follow(...)
        end
      end

      -- ponytail: get_items is the single chokepoint for every filesystem scan, but two
      -- code paths reach it with a directory that was removed on disk and then hit an
      -- unguarded uv.fs_opendir -> [Neo-tree ERROR] ... ENOENT:
      --   1. toggle_directory re-expands a saved/restored node whose dir is now gone
      --      (parent_id points at the missing dir; the existing-dir filter in
      --      handle_refresh_or_up only runs for parent_id == nil, so it is skipped).
      --   2. a scan whose root (state.path) no longer exists and did not come through
      --      _navigate_internal's walk-up (e.g. follow / direct calls).
      -- Guard both so the tree still opens instead of erroring. Ceiling: depends on the
      -- fs_scan module's `get_items` signature; pcall-guarded so a neo-tree API change
      -- degrades to the old noisy behaviour instead of breaking neo-tree.
      local uv = vim.uv or vim.loop
      local function is_dir(path)
        local st = path and uv.fs_stat(path)
        return st ~= nil and st.type == "directory"
      end
      local ok_scan, fs_scan = pcall(require, "neo-tree.sources.filesystem.lib.fs_scan")
      if ok_scan and type(fs_scan.get_items) == "function" then
        local get_items = fs_scan.get_items
        fs_scan.get_items = function(state, parent_id, path_to_reveal, callback, ...)
          -- A removed expanded folder has nothing left to scan; skip it.
          if parent_id ~= nil and not is_dir(parent_id) then
            if type(callback) == "function" then
              callback()
            end
            return
          end
          -- Root was removed: walk up to the nearest existing ancestor so the tree
          -- opens there rather than scanning a missing dir.
          if parent_id == nil and state and not is_dir(state.path) then
            local path = state.path
            while path and not is_dir(path) do
              local parent = vim.fn.fnamemodify(path, ":h")
              if not parent or parent == path then
                break
              end
              path = parent
            end
            if is_dir(path) then
              state.path = path
            end
          end
          return get_items(state, parent_id, path_to_reveal, callback, ...)
        end
      end
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
