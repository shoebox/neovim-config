return {
  {
    "ray-x/guihua.lua",
    lazy = true, -- Will be loaded by go.nvim when needed
  },
  {
    "ray-x/go.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "BufReadPre",
    opts = {
      dap_debug_gui = true,
      dap_debug_vt = true,
      diagnostic = false,
      -- Ensure go.nvim doesn't interfere with LSP config
      lsp_cfg = false,
      lsp_diag_update_in_insert = false,
      lsp_document_formatting = false,
      lsp_inlay_hints = { enable = false },
      lsp_semantic_highlights = false,
      run_in_floaterm = false,
      -- Additional settings for better build tag support
      build_tags = "integration,test,debug",
      test_runner = "go",
    },
    cmd = {
      "Go",
      "GoModInit",
      "GoModTidy",
      "GoNew",
      "GoFmt",
      "GoBuild",
      "GoAlt",
      "GoBreakToggle",
      "GoImpl",
      "GoRun",
      "GoInstall",
      "GoTest",
      "GoTestFunc",
      "GoTestCompile",
      "GoCoverage",
      "GoCoverageToggle",
      "GoCoverag",
      "GoGet",
      "GoModifyTags",
    },
    ft = {
      "go",
      "gohtmltmpl",
      "gomod",
      "gosum",
      "gotexttmpl",
      "gotmpl",
    },
    keys = {
      {
        "<leader>ga",
        "<cmd>GoAlt<cr>",
        desc = "NeoVim alt view",
      },
    },
  },
}
