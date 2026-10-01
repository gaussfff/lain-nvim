-- Keys: shows what is available after a prefix, so nothing has to be memorised.

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- Names for the prefixes this config uses; without them the popup
            -- only lists raw keys.
            spec = {
                { "<leader>c", group = "code" },
                { "<leader>f", group = "find" },
                { "<leader>g", group = "git" },
                { "<leader>n", group = "noice" },
                { "<leader>r", group = "rust" },
                { "<leader>s", group = "search & replace" },
                { "<leader>t", group = "test" },
                { "<leader>u", group = "ui" },
                { "<leader>w", group = "window" },
                { "<leader>x", group = "diagnostics" },
                { "[", group = "previous" },
                { "]", group = "next" },
                { "g", group = "goto" },
                { "z", group = "fold & scroll" },
            },
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Keymaps of this buffer",
            },
        },
    },
}
