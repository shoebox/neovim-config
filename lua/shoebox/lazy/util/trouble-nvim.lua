return {
    {
        "folke/trouble.nvim",
        config = function()
            local trouble = require("trouble")

            trouble.setup({
                mode = "document_diagnostics",
                auto_close = true,
                height = 15,
                multiline = true,
                indent_lines = true,
                use_diagnostic_signs = true,
            })
        end,
        keys = {
            {
                "<leader>td",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>tt",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>tb",
                function()
                    -- Open all files changed vs main so LSP attaches, then show trouble
                    local base = "main"
                    local files = vim.fn.systemlist("git diff --name-only --diff-filter=d " .. base .. "...HEAD")
                    if vim.v.shell_error ~= 0 or #files == 0 then
                        vim.notify("No changed files vs " .. base, vim.log.levels.INFO)
                        return
                    end
                    local cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
                    for _, f in ipairs(files) do
                        local path = cwd .. "/" .. f
                        vim.fn.bufadd(path)
                        vim.fn.bufload(path)
                    end
                    -- Give LSP a moment to attach and produce diagnostics
                    vim.defer_fn(function()
                        vim.cmd("Trouble diagnostics toggle")
                    end, 1000)
                end,
                desc = "Branch diagnostics vs main (Trouble)",
            },
        },
    },
}
