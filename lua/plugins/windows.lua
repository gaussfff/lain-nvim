-- Windows: one set of keys for Neovim splits and zellij panes.
--
-- Zellij binds Ctrl+hjkl to the vim-zellij-navigator plugin, which forwards the
-- key to Neovim when the pane runs it. smart-splits then either moves between
-- Neovim splits or, at the edge, tells zellij to switch panes.
-- See ~/.config/zellij/config.kdl.

return {
    {
        "mrjones2014/smart-splits.nvim",
        lazy = false,
        opts = {
            -- Zellij supports neither "wrap" nor "split" at the edge.
            at_edge = "stop",
            -- At the left or right edge of the layout, jump to the next tab.
            zellij_move_focus_or_tab = true,
        },
        keys = {
            {
                "<C-h>",
                function()
                    require("smart-splits").move_cursor_left()
                end,
                desc = "Go to left window",
            },
            {
                "<C-j>",
                function()
                    require("smart-splits").move_cursor_down()
                end,
                desc = "Go to lower window",
            },
            {
                "<C-k>",
                function()
                    require("smart-splits").move_cursor_up()
                end,
                desc = "Go to upper window",
            },
            {
                "<C-l>",
                function()
                    require("smart-splits").move_cursor_right()
                end,
                desc = "Go to right window",
            },
            {
                "<A-h>",
                function()
                    require("smart-splits").resize_left()
                end,
                desc = "Resize window left",
            },
            {
                "<A-j>",
                function()
                    require("smart-splits").resize_down()
                end,
                desc = "Resize window down",
            },
            {
                "<A-k>",
                function()
                    require("smart-splits").resize_up()
                end,
                desc = "Resize window up",
            },
            {
                "<A-l>",
                function()
                    require("smart-splits").resize_right()
                end,
                desc = "Resize window right",
            },
            {
                "<leader>wh",
                function()
                    require("smart-splits").swap_buf_left()
                end,
                desc = "Swap buffer left",
            },
            {
                "<leader>wj",
                function()
                    require("smart-splits").swap_buf_down()
                end,
                desc = "Swap buffer down",
            },
            {
                "<leader>wk",
                function()
                    require("smart-splits").swap_buf_up()
                end,
                desc = "Swap buffer up",
            },
            {
                "<leader>wl",
                function()
                    require("smart-splits").swap_buf_right()
                end,
                desc = "Swap buffer right",
            },
        },
    },
}
