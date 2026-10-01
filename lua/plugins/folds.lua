-- Folds: ufo builds them from LSP fold ranges instead of indentation.

return {
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = { "BufReadPre", "BufNewFile" },
        init = function()
            -- ufo needs folds open by default; a small foldlevel would keep
            -- closing them as the ranges get recomputed.
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
        end,
        keys = {
            {
                "zR",
                function()
                    require("ufo").openAllFolds()
                end,
                desc = "Open all folds",
            },
            {
                "zM",
                function()
                    require("ufo").closeAllFolds()
                end,
                desc = "Close all folds",
            },
            {
                "zr",
                function()
                    require("ufo").openFoldsExceptKinds()
                end,
                desc = "Open folds except kinds",
            },
            {
                "zm",
                function()
                    require("ufo").closeFoldsWith()
                end,
                desc = "Close folds with level",
            },
        },
        opts = {
            -- Fall back to indentation for filetypes without a language server.
            provider_selector = function()
                return { "lsp", "indent" }
            end,
        },
    },
}
