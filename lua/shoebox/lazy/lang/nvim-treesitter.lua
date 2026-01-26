return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    config = function()
      local parsers = {
        "bash",
        "diff",
        "git_rebase",
        "gitcommit",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "json",
        "lua",
        "nix",
        "markdown",
        "markdown_inline",
        "regex",
        "toml",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      }

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

      -- Enable treesitter highlighting for supported filetypes
      vim.api.nvim_create_autocmd({ "FileType" }, {
        callback = function(event)
          local ignored_fts = {
            "snacks_dashboard",
            "snacks_notif",
            "snacks_input",
            "prompt",
            "fidget",
          }

          if vim.tbl_contains(ignored_fts, event.match) then
            return
          end

          -- Check if parser is installed before trying to start treesitter
          local lang = vim.treesitter.language.get_lang(event.match) or event.match
          local has_parser = pcall(vim.treesitter.language.add, lang)

          if has_parser then
            pcall(vim.treesitter.start, event.buf)
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          elseif not installation_complete then
            -- If installation is still in progress, retry after a delay
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(event.buf) then
                local retry_has_parser = pcall(vim.treesitter.language.add, lang)
                if retry_has_parser then
                  pcall(vim.treesitter.start, event.buf)
                  vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
              end
            end, 500)
          end
        end,
      })
    end,
    build = ":TSUpdate",
  },
}
