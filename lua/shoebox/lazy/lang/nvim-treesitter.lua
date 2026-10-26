return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local INSTALL_TIMEOUT_MS = 1000
      local RETRY_DELAY_MS = 500

      local parsers = {
        "bash",
        "diff",
        "git_rebase",
        "gitcommit",
        "go",
        "gomod",
        "gosum",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "nix",
        "regex",
        "toml",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      }

      -- Custom parsers not in nvim-treesitter's default list.
      -- install() calls reload_parsers() which wipes these, so they must be
      -- re-registered right before each install() call.
      local custom_parsers = {
        gherkin = {
          install_info = {
            url = "https://github.com/binhtddev/tree-sitter-gherkin",
            files = { "src/parser.c" },
            branch = "main",
          },
        },
        brightscript = {
          install_info = {
            url = "https://github.com/ajdelcimmuto/tree-sitter-brightscript",
            files = { "src/parser.c" },
            branch = "main",
          },
        },
        brighterscript = {
          install_info = {
            url = "https://github.com/AnishShah1803/treesitter-brighterscript",
            files = { "src/parser.c" },
            branch = "main",
          },
        },
      }

      local function register_custom_parsers()
        local p = require("nvim-treesitter.parsers")
        for name, config in pairs(custom_parsers) do
          p[name] = config
        end
      end

      -- Register for :TSUpdate build command
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = register_custom_parsers,
      })

      -- Filetype detection for extensions without built-in support
      vim.filetype.add({
        extension = {
          brs = "brightscript",
          bs = "brighterscript",
          mdc = "markdown",
        },
      })

      -- Install all parsers: register custom ones first, then install everything in one call
      local installation_complete = false

      vim.schedule(function()
        register_custom_parsers()
        local all = vim.list_extend(vim.deepcopy(parsers), vim.tbl_keys(custom_parsers))
        require("nvim-treesitter").install(all)

        -- TODO: install() is async; this timeout is a best-effort heuristic
        vim.defer_fn(function()
          installation_complete = true
        end, INSTALL_TIMEOUT_MS)
      end)

      local ignored_fts = {
        snacks_dashboard = true,
        snacks_notif = true,
        snacks_input = true,
        prompt = true,
      }

      local function enable_ts(bufnr)
        pcall(vim.treesitter.start, bufnr)
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      local function start_treesitter(bufnr, filetype)
        if ignored_fts[filetype] then
          return
        end

        local lang = vim.treesitter.language.get_lang(filetype) or filetype
        local has_parser = pcall(vim.treesitter.language.add, lang)

        if has_parser then
          enable_ts(bufnr)
        elseif not installation_complete then
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              if pcall(vim.treesitter.language.add, lang) then
                enable_ts(bufnr)
              end
            end
          end, RETRY_DELAY_MS)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(event)
          start_treesitter(event.buf, event.match)
        end,
      })

      vim.api.nvim_create_autocmd("FileChangedShellPost", {
        callback = function(event)
          pcall(vim.treesitter.stop, event.buf)
          start_treesitter(event.buf, vim.bo[event.buf].filetype)
        end,
      })
    end,
  },
}
