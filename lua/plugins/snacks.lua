-- Snacks: a collection of small quality-of-life modules, enabled one by one.
-- Modules that would duplicate something already installed stay off:
-- notifier, indent, explorer and picker. The dashboard lives in dashboard.lua.

return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@module "snacks"
        ---@type snacks.Config
        opts = {
            -- Strip heavy features from very large files so they still open.
            bigfile = { enabled = true },
            -- Render a file before the rest of the startup work finishes.
            quickfile = { enabled = true },
            -- Replace vim.ui.input with a floating prompt.
            input = { enabled = true },
            -- Smooth scrolling.
            scroll = { enabled = true },
            -- words is off: vim-illuminate does the same job with more providers.
            -- Scratch terminals bound to keys, see below.
            terminal = {},
        },
        keys = {
            {
                "<leader>T",
                function()
                    require("snacks").terminal()
                end,
                desc = "Terminal",
            },
            {
                "<leader>ge",
                function()
                    require("snacks").terminal("iex -S mix")
                end,
                desc = "Elixir: IEx",
            },
            {
                "<leader>gr",
                function()
                    require("snacks").terminal("cargo watch -x test")
                end,
                desc = "Rust: cargo watch",
            },
        },
    },
}
