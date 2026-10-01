-- LSP: language servers, installed by Mason and enabled with the
-- native vim.lsp API (Neovim 0.11+).

-- Packages Mason keeps installed. rust_analyzer is missing on purpose: it
-- ships with the toolchain, and rustaceanvim configures it (see rust.lua).
local ensure_installed = {
    "expert", -- Elixir
    "ts_ls", -- TypeScript / JavaScript
    "vue_ls", -- Vue single-file components
    "svelte", -- Svelte and SvelteKit
    "eslint", -- linter for projects with an ESLint config
    "oxlint", -- linter used by current NestJS and Vite templates
    "gopls", -- Go
    "postgres_lsp", -- PostgreSQL
    "lua_ls", -- Lua
    "bashls", -- Bash / sh
    "fish_lsp", -- Fish
    "jsonls", -- JSON
    "yamlls", -- YAML
    "taplo", -- TOML
    "prettierd", -- formatter for js/ts/json/css
    "stylua", -- formatter for lua
    "shfmt", -- formatter for bash/sh
    "gofumpt", -- formatter for go
    "sql-formatter", -- formatter for sql
    "goimports", -- import fixer for go
    "gotestsum", -- test runner neotest-golang drives
}

return {
    -- Not lazy: the installer checks for missing packages on VimEnter.
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        lazy = false,
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
        },
        opts = { ensure_installed = ensure_installed },
    },

    -- Teaches lua_ls about the Neovim API and installed plugin modules.
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason-org/mason-lspconfig.nvim",
            -- Must load first: it registers completion capabilities that the
            -- servers only pick up when they start.
            "saghen/blink.cmp",
            -- Schema catalog for jsonls and yamlls.
            "b0o/schemastore.nvim",
        },
        config = function()
            -- Keys are config names from nvim-lspconfig, see :help lspconfig-all.
            local servers = {
                expert = {},

                -- Vue SFCs need two servers: vue_ls owns the template and style
                -- blocks, while ts_ls handles the script through a Vue plugin.
                vue_ls = {},

                svelte = {},

                ts_ls = {
                    filetypes = {
                        "javascript",
                        "javascriptreact",
                        "javascript.jsx",
                        "typescript",
                        "typescriptreact",
                        "typescript.tsx",
                        "vue",
                    },
                    init_options = {
                        plugins = {
                            {
                                name = "@vue/typescript-plugin",
                                location = vim.fn.expand(
                                    "$MASON/packages/vue-language-server/node_modules/@vue/language-server"
                                ),
                                languages = { "vue" },
                            },
                        },
                    },
                },

                -- gopls needs almost nothing: unusedparams, nilness and the
                -- other analysers are already on, and staticcheck is left unset
                -- so gopls picks its curated subset instead of every check.
                gopls = {
                    settings = {
                        gopls = {
                            gofumpt = true, -- match the formatter conform runs on save
                        },
                    },
                },

                -- Upstream only attaches next to postgres-language-server.jsonc,
                -- yet the file is optional: without it the server still reports
                -- syntax errors and migration lints. With it, it also checks
                -- queries against a live database.
                postgres_lsp = {
                    root_markers = { "postgres-language-server.jsonc", ".git" },
                },

                -- Both linters attach only where the project asks for them:
                -- eslint needs an ESLint config, oxlint a config file or a
                -- package.json that mentions it. Each prefers the project's own
                -- binary from node_modules/.bin over the Mason one.
                eslint = {},

                -- Upstream leaves workspace_required unset, so with no config
                -- found oxlint still starts with root_dir = nil and lints every
                -- JS/TS buffer by its own defaults. eslint guards this the same
                -- way; this makes oxlint behave consistently.
                oxlint = { workspace_required = true },

                bashls = {},

                fish_lsp = {},

                -- Validates Cargo.toml, pyproject.toml and friends out of the box.
                taplo = {},

                -- Everything else for Lua lives in .luarc.json and lazydev.nvim.
                lua_ls = {
                    settings = {
                        Lua = {
                            format = { enable = false }, -- stylua does the formatting
                        },
                    },
                },

                jsonls = {
                    settings = {
                        json = {
                            schemas = require("schemastore").json.schemas(),
                            validate = { enable = true },
                        },
                    },
                },

                yamlls = {
                    settings = {
                        yaml = {
                            -- The built-in store must be off for schemastore.nvim to work.
                            schemaStore = { enable = false, url = "" },
                            schemas = require("schemastore").yaml.schemas(),
                        },
                    },
                },
            }

            -- nvim-ufo folds from LSP ranges, but Neovim does not advertise
            -- that capability on its own. Merged into whatever blink.cmp set.
            vim.lsp.config("*", {
                capabilities = {
                    textDocument = {
                        foldingRange = {
                            dynamicRegistration = false,
                            lineFoldingOnly = true,
                        },
                    },
                },
            })

            -- Enabled manually below so Mason and system servers work the same way.
            require("mason-lspconfig").setup({ automatic_enable = false })

            for name, opts in pairs(servers) do
                vim.lsp.config(name, opts)
                vim.lsp.enable(name)
            end
        end,
    },
}
