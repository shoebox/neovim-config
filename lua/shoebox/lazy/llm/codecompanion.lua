local function prompt_library()
  local coding = require("shoebox.llm.prompts.coding")
  local codereview = require("shoebox.llm.prompts.codereview")
  local commit = require("shoebox.llm.prompts.commit")
  local docs = require("shoebox.llm.prompts.docs")
  local refactoring = require("shoebox.llm.prompts.refactoring")
  local unittests = require("shoebox.llm.prompts.unittests")
  return {
    ["Coding workflow"] = coding.Basic,
    ["Code-review - Basic"] = codereview.Basic,
    ["Code-review - General"] = codereview.General,
    ["Code-review - SOLID"] = codereview.Solid,
    ["Doc - Create article"] = docs.CreateArticle,
    ["Doc - Rewrite article"] = docs.RewriteArticle,
    ["Generate a commit message"] = commit.ConventionalCommit,
    ["Refactoring - Add missing documentation"] = refactoring.MissingDoc,
    ["Refactoring - Find better naming"] = refactoring.BetterNaming,
    ["Refactoring - Find matching pattern"] = refactoring.MatchingPattern,
    ["Refactoring - Optimize logging"] = refactoring.BetterLogging,
    ["Refactoring - Optimize"] = refactoring.Optimize,
    ["Refactoring - SOLID"] = refactoring.Solid,
    ["Unit Tests - Gherkin test-cases"] = unittests.Gherkin,
  }
end

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "COMMIT_EDITMSG",
  callback = function(args)
    local bufnr = args.buf
    -- Check if we've already shown the prompt in this buffer
    if vim.b[bufnr].commit_prompt_shown then
      return
    end
    vim.b[bufnr].commit_prompt_shown = true
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.cmd("CodeCompanion /conventional_commit")
      end
    end, 50)
  end,
})

return {
  {
    "olimorris/codecompanion.nvim",
    cmd = {
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanion",
    },
    dependencies = {
      "github/copilot.vim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<leader>za",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v", "x" },
        desc = "Code Companion - Actions",
      },
      {
        "<leader>]",
        mode = { "n", "v" },
        "<cmd>CodeCompanionActions<cr>",
        desc = "Code Companion - Actions",
      },
      {
        "<leader>zc",
        "<cmd>CodeCompanionChat<cr>",
        desc = "Code Companion - Chat",
      },
    },
    opts = {
      adapters = {
        http = {
          opts = {
            show_defaults = false,
          },
        },
      },
      prompt_library = prompt_library(),
      display = {
        action_palette = {
          opts = {
            show_default_actions = true,
            show_default_prompt_library = false,
            width = 20,
            height = 10,
          },
        },
        chat = {
          window = {
            show_references = false,
            show_header_separator = true,
            show_settings = false,
            width = 0.33,
          },
        },
      },
      memory = {
        opts = {
          chat = {
            enabled = true,
          },
        },
      },
      strategies = {
        chat = {
          adapter = "auggie_cli",
          -- adapter = {
          --   name = "copilot",
          --   model = "claude-sonnet-4.5",
          -- },
          keymaps = {
            clear = {
              modes = { n = "gxx" },
              index = 6,
              callback = "keymaps.clear",
              description = "Clear Chat",
            },
            debug = {
              modes = {
                n = "gdd",
              },
              index = 16,
              callback = "keymaps.debug",
              description = "View debug info",
            },
          },
        },
        inline = {
          adapter = "copilot",
        },
        cmd = {
          adapter = "auggie_cli",
        },
      },
    },
  },
}
