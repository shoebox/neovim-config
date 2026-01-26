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
        },
    },
}
