-- UI: cmdline, messages, notifications and icons.

return {
    -- Colorscheme. Loaded first so nothing renders unstyled.
    {
        "AlexvZyl/nordic.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("nordic").setup({
                bold_keywords = true,
                italic_comments = true,
                -- Delimiter ships italic, which drags ":" and "," in code
                -- along with it and makes type annotations hard to read.
                on_highlight = function(highlights)
                    highlights.Delimiter.italic = false
                end,
                -- Keep the palette close to real Nord instead of warming it up.
                reduced_blue = false,
                cursorline = { theme = "dark" },
                noice = { style = "classic" },
            })
            -- colors/nordic.vim calls load() for us; calling it directly
            -- trips a lua_ls warning because upstream marks the argument required.
            vim.cmd.colorscheme("nordic")
        end,
    },

    -- Statusline.
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function()
            -- Names of the language servers attached to the current buffer.
            local function lsp_clients()
                local names = {}
                for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                    names[#names + 1] = client.name
                end
                return table.concat(names, ", ")
            end

            return {
                options = {
                    theme = "nordic", -- ships with the colorscheme
                    globalstatus = true, -- one line for the whole editor, not per split
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                    disabled_filetypes = { statusline = { "dashboard" } },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { { lsp_clients, icon = "" }, "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            }
        end,
    },

    -- Breadcrumbs in the winbar: path plus the symbol the cursor sits in.
    {
        "Bekaboo/dropbar.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            {
                "<leader>;",
                function()
                    require("dropbar.api").pick()
                end,
                desc = "Pick symbol in winbar",
            },
            {
                "[;",
                function()
                    require("dropbar.api").goto_context_start()
                end,
                desc = "Go to context start",
            },
            {
                "];",
                function()
                    require("dropbar.api").select_next_context()
                end,
                desc = "Select next context",
            },
        },
        opts = {},
    },

    -- Indent guides.
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl", -- module name differs from the repo name
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            indent = { char = "│" },
            scope = { enabled = true, show_start = false, show_end = false },
            exclude = {
                filetypes = {
                    "dashboard",
                    "oil",
                    "lspinfo",
                    "checkhealth",
                    "help",
                    "man",
                    "gitcommit",
                    "",
                },
            },
        },
    },

    -- Icons. Oil and most plugins prefer mini.icons; nvim-web-devicons is
    -- there for the ones that ask for it by name.
    { "nvim-mini/mini.icons", opts = {} },
    { "nvim-tree/nvim-web-devicons", opts = {} },

    -- Replaces the cmdline, messages and popupmenu with floating windows.
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        keys = {
            { "<leader>nl", "<cmd>Noice last<cr>", desc = "Noice: last message" },
            { "<leader>nh", "<cmd>Noice history<cr>", desc = "Noice: message history" },
            { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Noice: dismiss all" },
        },
        ---@module "noice"
        ---@type NoiceConfig
        opts = {
            lsp = {
                -- Render LSP docs with Treesitter instead of the built-in markdown.
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
            },
            cmdline = {
                -- Classic cmdline at the bottom instead of a floating popup.
                view = "cmdline",
            },
            presets = {
                bottom_search = true, -- classic bottom cmdline for / and ?
                long_message_to_split = true, -- long messages open in a split
                lsp_doc_border = true, -- border around hover and signature help
            },
        },
    },
}
