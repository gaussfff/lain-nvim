-- Trouble: a proper list for diagnostics, references and quickfix entries.

return {
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics: project" },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Diagnostics: this buffer",
            },
            {
                "<leader>xs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols of this file",
            },
            {
                "<leader>xl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP references and definitions",
            },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
        },
        opts = {},
    },
}
