-- Replace: project-wide find and replace with a live preview.

return {
    {
        "MagicDuck/grug-far.nvim",
        cmd = { "GrugFar", "GrugFarWithin" },
        keys = {
            {
                "<leader>sr",
                function()
                    require("grug-far").open()
                end,
                desc = "Search and replace in project",
            },
            {
                "<leader>sw",
                function()
                    require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
                end,
                desc = "Search and replace: word under cursor",
            },
            {
                "<leader>sf",
                function()
                    require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
                end,
                desc = "Search and replace: this file only",
            },
            {
                "<leader>sr",
                mode = "v",
                function()
                    require("grug-far").with_visual_selection()
                end,
                desc = "Search and replace: selection",
            },
        },
        opts = {
            -- Keep results readable in a vertical split rather than full width.
            windowCreationCommand = "vsplit",
        },
    },
}
