local vim = vim

return {
  {
    "mistweaverco/kulala.nvim",
    setup = function()
      vim.filetype.add({
        extension = {
          http = "http",
        },
      })
    end,
    opts = {
      contenttypes = {
        ["application/json"] = {
          ft = "json",
        },
        ["application/problem+json"] = {
          ft = "json",
        },
        ["application/xml"] = {
          ft = "xml",
        },
        ["text/html"] = {
          ft = "html",
        },
      },
      -- contenttypes = {
      --   ["application/json"] = {
      --     ft = "json",
      --     formatter = vim.fn.executable("jq") == 1 and { "jq", "." },
      --     pathresolver = function(...)
      --       return require("kulala.parser.jsonpath").parse(...)
      --     end,
      --   },
      --   ["application/problem+json"] = "application/json",
      --   ["application/graphql"] = {
      --     ft = "graphql",
      --     formatter = vim.fn.executable("prettier") == 1
      --       and { "prettier", "--stdin-filepath", "file.graphql" },
      --     pathresolver = nil,
      --   },
      --   ["application/javascript"] = {
      --     ft = "javascript",
      --     formatter = vim.fn.executable("prettier") == 1
      --       and { "prettier", "--stdin-filepath", "file.js" },
      --     pathresolver = nil,
      --   },
      --   ["application/lua"] = {
      --     ft = "lua",
      --     formatter = vim.fn.executable("stylua") == 1 and { "stylua", "-" },
      --     pathresolver = nil,
      --   },
      --   ["application/graphql-response+json"] = "application/json",
      --   ["application/xml"] = {
      --     ft = "xml",
      --     formatter = vim.fn.executable("xmllint") == 1 and { "xmllint", "--format", "-" },
      --     pathresolver = vim.fn.executable("xmllint") == 1
      --       and { "xmllint", "--xpath", "{{path}}", "-" },
      --   },
      --   ["text/html"] = {
      --     ft = "html",
      --     formatter = vim.fn.executable("prettier") == 1
      --       and { "prettier", "--stdin-filepath", "file.html" },
      --     pathresolver = nil,
      --   },
      -- },
      ui = {
        -- Configure the default view to handle success/error differently
        default_view = function(response)
          -- Check if request was successful based on assertions (if available) or status code
          local has_assertions = response.assert_status ~= nil
          local is_success

          if has_assertions then
            -- Use assertion results if assertions are defined
            is_success = response.assert_status == true
          else
            -- Fallback to status code check if no assertions
            is_success = response.response_code >= 200 and response.response_code < 300
          end

          if is_success then
            -- Extract hostname and path from URL
            local url_display = response.url or "unknown"
            local hostname = url_display:match("https?://([^/]+)") or url_display
            local path_and_query = url_display:match("https?://[^/]+(/.*)") or "/"

            -- Truncate very long paths/queries for readability
            if #path_and_query > 50 then
              path_and_query = path_and_query:sub(1, 47) .. "..."
            end

            -- Create detailed success message
            local success_indicator = has_assertions and "✅🧪" or "✅"
            local message = string.format(
              "%s %s %s%s → %d",
              success_indicator,
              response.method or "REQUEST",
              hostname,
              path_and_query,
              response.response_code or 200
            )

            -- For successful requests, show a notification and don't open the report window
            vim.notify(message, vim.log.levels.INFO, {
              title = "Kulala - All Good",
              timeout = 3000,
            })
            -- Return early to prevent showing the response window
            return
          else
            -- For errors, show the default body view which will open the report window
            require("kulala.ui").show_body()
          end
        end,
        -- Configure report to show only on errors
        report = {
          show_script_output = "on_error",
          show_asserts_output = "on_error",
          show_summary = "on_error",
        },
      },
      lsp = {
        enable = true,
      },
    },
    ft = { "http", "rest" },
    keys = {
      {
        "<leader>kr",
        function()
          require("kulala").run()
        end,
        ft = "http",
        desc = "Kulala run request",
      },
      {
        "<leader>ka",
        function()
          require("kulala").replay()
        end,
        desc = "Kulala replay last request",
      },
      {
        "<leader>kt",
        function()
          require("kulala").toggle_view()
        end,
        desc = "Kulala toggle view",
      },
      {
        "<leader>ke",
        function()
          require("kulala").set_selected_env()
        end,
        desc = "Kulala - select environment",
      },
      {
        "<leader>kp",
        function()
          require("kulala").scratchpad()
        end,
        desc = "Kulala - open srachtpad",
      },
      {
        "<leader>ko",
        function()
          require("kulala").open()
        end,
        desc = "Kulala - open kulala",
      },
    },
  },
}
