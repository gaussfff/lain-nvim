-- Illuminate: highlights the other uses of the symbol under the cursor.

return {
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("illuminate").configure({
                -- LSP knows real references; treesitter and regex cover
                -- buffers where no server is attached.
                providers = { "lsp", "treesitter", "regex" },
                delay = 100,
                large_file_cutoff = 2000,
                filetypes_denylist = { "oil", "dashboard", "codediff-explorer", "neo-tree" },
                -- Defaults are <A-n>, <A-p> and <A-i>, all taken by zellij.
                disable_keymaps = true,
            })

            -- plugin/illuminate.vim runs before this config and has already
            -- set its defaults, so disable_keymaps alone cannot stop them.
            pcall(vim.keymap.del, "n", "<A-n>")
            pcall(vim.keymap.del, "n", "<A-p>")
            pcall(vim.keymap.del, "o", "<A-i>")
            pcall(vim.keymap.del, "x", "<A-i>")

            local map = vim.keymap.set
            map("n", "]r", function()
                require("illuminate").goto_next_reference(false)
            end, { desc = "Next reference" })
            map("n", "[r", function()
                require("illuminate").goto_prev_reference(false)
            end, { desc = "Previous reference" })
            map({ "o", "x" }, "ir", function()
                require("illuminate").textobj_select()
            end, { desc = "Reference" })
        end,
    },
}
