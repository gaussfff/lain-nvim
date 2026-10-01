-- Format: Conform runs external formatters and falls back to the LSP
-- for filetypes that have none configured.

-- prettierd is prettier running as a daemon; plain prettier is the fallback.
local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format({ async = true })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },
        ---@module "conform"
        ---@type conform.setupOpts
        opts = {
            formatters_by_ft = {
                rust = { "rustfmt" },

                -- mix format runs from the mix.exs root, so .formatter.exs applies.
                elixir = { "mix" },
                eelixir = { "mix" },
                heex = { "mix" },

                javascript = prettier,
                javascriptreact = prettier,
                typescript = prettier,
                typescriptreact = prettier,
                -- Prettier handles .vue natively. .svelte is deliberately absent:
                -- it needs prettier-plugin-svelte, and the svelte language
                -- server formats those files through the lsp_format fallback.
                vue = prettier,
                json = prettier,
                jsonc = prettier,
                css = prettier,
                scss = prettier,
                html = prettier,
                yaml = prettier,
                markdown = prettier,

                -- goimports rewrites the import block and runs gofmt; gofumpt
                -- then applies its stricter rules on top.
                go = { "goimports", "gofumpt" },

                sql = { "sql_formatter" },

                toml = { "taplo" }, -- same binary as the TOML language server

                lua = { "stylua" },

                sh = { "shfmt" },
                bash = { "shfmt" },
                fish = { "fish_indent" }, -- ships with fish itself
            },

            default_format_opts = {
                lsp_format = "fallback",
            },

            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                -- 3s instead of the default 500ms: mix format boots the BEAM.
                return { timeout_ms = 3000 }
            end,

            formatters = {
                mix = { require_cwd = true }, -- skip outside a mix project

                -- Without a dialect sql-formatter fails on the first "::" cast.
                -- A project's .sql-formatter.json is authoritative; elsewhere
                -- use Postgres and follow the buffer's indent, like shfmt does.
                sql_formatter = {
                    cwd = function(_, ctx)
                        return vim.fs.root(ctx.dirname, ".sql-formatter.json")
                    end,
                    args = function(_, ctx)
                        if vim.fs.root(ctx.dirname, ".sql-formatter.json") then
                            return {}
                        end
                        local config = { language = "postgresql", tabWidth = ctx.shiftwidth }
                        return { "--config", vim.json.encode(config) }
                    end,
                },
            },
        },

        init = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

            -- :FormatDisable! disables autoformat for the current buffer only.
            vim.api.nvim_create_user_command("FormatDisable", function(args)
                if args.bang then
                    vim.b.disable_autoformat = true
                else
                    vim.g.disable_autoformat = true
                end
            end, { desc = "Disable autoformat on save", bang = true })

            vim.api.nvim_create_user_command("FormatEnable", function()
                vim.b.disable_autoformat = false
                vim.g.disable_autoformat = false
            end, { desc = "Re-enable autoformat on save" })
        end,
    },
}
