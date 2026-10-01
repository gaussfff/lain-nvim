-- Test: run tests from the buffer, see results in the gutter.

return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            -- Adapters translate between neotest and each test runner.
            "jfpedroza/neotest-elixir",
            "nvim-neotest/neotest-jest",
            "marilari88/neotest-vitest",
            "fredrikaverpil/neotest-golang",
        },
        keys = {
            {
                "<leader>tt",
                function()
                    require("neotest").run.run()
                end,
                desc = "Test: nearest",
            },
            {
                "<leader>tf",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Test: file",
            },
            {
                "<leader>tl",
                function()
                    require("neotest").run.run_last()
                end,
                desc = "Test: repeat last",
            },
            {
                "<leader>ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Test: summary panel",
            },
            {
                "<leader>to",
                function()
                    require("neotest").output.open({ enter = true })
                end,
                desc = "Test: output",
            },
            {
                "<leader>tp",
                function()
                    require("neotest").output_panel.toggle()
                end,
                desc = "Test: output panel",
            },
            {
                "<leader>tx",
                function()
                    require("neotest").run.stop()
                end,
                desc = "Test: stop",
            },
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("rustaceanvim.neotest"),
                    require("neotest-elixir"),
                    require("neotest-jest"),
                    require("neotest-vitest"),
                    -- gotestsum wraps go test and prints readable output next to
                    -- the JSON stream neotest parses.
                    require("neotest-golang")({ runner = "gotestsum" }),
                },
            })
        end,
    },
}
