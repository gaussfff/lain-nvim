-- Git: a full TUI for everyday work, a VSCode-style diff viewer, and
-- per-line authorship inside ordinary buffers.

return {
    -- Signs in the gutter for changed lines, plus who wrote the current one.
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text_pos = "eol",
                delay = 300,
                ignore_whitespace = true,
            },
            current_line_blame_formatter = "  <author>, <author_time:%d.%m.%Y> — <summary>",
        },
        keys = {
            {
                "<leader>gb",
                function()
                    require("gitsigns").blame_line({ full = true })
                end,
                desc = "Git: blame this line",
            },
            {
                "<leader>gB",
                function()
                    require("gitsigns").blame()
                end,
                desc = "Git: blame whole file",
            },
            {
                "<leader>gt",
                function()
                    require("gitsigns").toggle_current_line_blame()
                end,
                desc = "Git: toggle inline blame",
            },
            {
                "<leader>gv",
                function()
                    require("gitsigns").preview_hunk()
                end,
                desc = "Git: preview hunk",
            },
            {
                "]h",
                function()
                    require("gitsigns").nav_hunk("next")
                end,
                desc = "Next hunk",
            },
            {
                "[h",
                function()
                    require("gitsigns").nav_hunk("prev")
                end,
                desc = "Previous hunk",
            },
        },
    },

    -- lazygit in a floating window; the binary comes from Homebrew.
    {
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Git: lazygit" },
            {
                "<leader>gc",
                "<cmd>LazyGitCurrentFile<cr>",
                desc = "Git: lazygit for this file's repo",
            },
            {
                "<leader>gl",
                "<cmd>LazyGitFilterCurrentFile<cr>",
                desc = "Git: commits touching this file",
            },
        },
        init = function()
            vim.g.lazygit_floating_window_scaling_factor = 0.9
            vim.g.lazygit_floating_window_border_chars =
                { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
            vim.g.lazygit_floating_window_use_plenary = 1
        end,
    },

    {
        "esmuellert/codediff.nvim",
        cmd = "CodeDiff",
        keys = {
            { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Git: changed files" },
            { "<leader>gh", "<cmd>CodeDiff history<cr>", desc = "Git: commit history" },
            { "<leader>gf", "<cmd>CodeDiff file HEAD<cr>", desc = "Git: this file vs HEAD" },
        },
        opts = {
            view = {
                -- +/- markers in the sign column next to changed lines.
                gutter_signs = true,
            },
            explorer = {
                view_mode = "tree",
            },
        },
    },
}
