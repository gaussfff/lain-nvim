-- Yank: keeps a searchable history of yanks instead of just the last one.

return {
    {
        "gbprod/yanky.nvim",
        dependencies = { "kkharji/sqlite.lua" },
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            ring = {
                history_length = 100,
                -- Survives restarts; without sqlite the history is per-session.
                storage = "sqlite",
            },
            highlight = { on_put = true, on_yank = true, timer = 200 },
        },
        keys = {
            { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank" },
            { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
            { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
            {
                "gp",
                "<Plug>(YankyGPutAfter)",
                mode = { "n", "x" },
                desc = "Put after, cursor at end",
            },
            {
                "gP",
                "<Plug>(YankyGPutBefore)",
                mode = { "n", "x" },
                desc = "Put before, cursor at end",
            },
            -- Upstream suggests <C-n>/<C-p>; zellij owns both.
            { "]y", "<Plug>(YankyNextEntry)", desc = "Cycle to next yank" },
            { "[y", "<Plug>(YankyPreviousEntry)", desc = "Cycle to previous yank" },
            { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put after, reindent" },
            { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put before, reindent" },
            { "<leader>fy", "<cmd>Telescope yank_history<cr>", desc = "Find: yank history" },
        },
        config = function(_, opts)
            require("yanky").setup(opts)
            pcall(require("telescope").load_extension, "yank_history")
        end,
    },
}
