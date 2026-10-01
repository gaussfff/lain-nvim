-- Telescope: fuzzy finder over files, text, buffers and LSP symbols.
--

return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- Native sorter, much faster on large repos. Needs make and a C compiler.
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find: files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find: text in project" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find: open buffers" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Find: recent files" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find: help" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Find: keymaps" },
            { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Find: diagnostics" },
            {
                "<leader>fs",
                "<cmd>Telescope lsp_document_symbols<cr>",
                desc = "Find: symbols in file",
            },
            {
                "<leader>fw",
                "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
                desc = "Find: symbols in project",
            },
            {
                "<leader>f/",
                "<cmd>Telescope current_buffer_fuzzy_find<cr>",
                desc = "Find: in this buffer",
            },
            -- Live preview while scrolling; the choice lasts for this session.
            {
                "<leader>uc",
                "<cmd>Telescope colorscheme<cr>",
                desc = "UI: change colorscheme",
            },
        },
        opts = {
            defaults = {
                path_display = { "truncate" },
                -- Preview and results side by side, prompt at the top.
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top", preview_width = 0.55 },
                sorting_strategy = "ascending",
            },
            pickers = {
                find_files = { hidden = true },
                colorscheme = { enable_preview = true },
            },
        },
        config = function(_, opts)
            require("telescope").setup(opts)
            require("telescope").load_extension("fzf")
        end,
    },
}
