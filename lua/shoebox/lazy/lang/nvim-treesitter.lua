return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    -- event = "VeryLazy",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local parsers = {
        "bash",
        "diff",
        "gherkin",
        "git_rebase",
        "gitcommit",
        "go",
        "gomod",
        "gosum",
        "json",
        "lua",
        "nix",
        "regex",
        "toml",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      }

      -- Register custom parser source for gherkin via TSUpdate hook
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          require("nvim-treesitter.parsers").gherkin = {
            install_info = {
              url = "https://github.com/binhtddev/tree-sitter-gherkin",
              files = { "src/parser.c" },
              branch = "main",
            },
          }
        end,
      })

      -- Track installation status
      local installation_complete = false

      -- Install parsers asynchronously after nvim-treesitter is loaded
      vim.schedule(function()
        require("nvim-treesitter").install(parsers)
        -- Mark installation as complete after a delay to ensure parsers are ready
        vim.defer_fn(function()
          installation_complete = true
        end, 1000)
      end)

      local ignored_fts = {
        snacks_dashboard = true,
        snacks_notif = true,
        snacks_input = true,
        prompt = true,
        fidget = true,
      }

      -- Enable treesitter highlighting and indentation for a buffer
      local function enable_ts(bufnr)
        pcall(vim.treesitter.start, bufnr)
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      -- Helper function to start treesitter for a buffer
      local function start_treesitter(bufnr, filetype)
        if ignored_fts[filetype] then
          return
        end

        local lang = vim.treesitter.language.get_lang(filetype) or filetype
        local has_parser = pcall(vim.treesitter.language.add, lang)

        if has_parser then
          enable_ts(bufnr)
        elseif not installation_complete then
          -- If installation is still in progress, retry after a delay
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              local retry_has_parser = pcall(vim.treesitter.language.add, lang)
              if retry_has_parser then
                enable_ts(bufnr)
              end
            end
          end, 500)
        end
      end

      -- Enable treesitter highlighting for supported filetypes
      vim.api.nvim_create_autocmd({ "FileType" }, {
        callback = function(event)
          start_treesitter(event.buf, event.match)
        end,
      })

      -- Re-attach treesitter when file is changed externally (e.g., by AI tools)
      vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
        callback = function(event)
          -- Stop any existing treesitter instance
          pcall(vim.treesitter.stop, event.buf)
          -- Restart treesitter
          local ft = vim.bo[event.buf].filetype
          start_treesitter(event.buf, ft)
        end,
      })
    end,
  },
}
