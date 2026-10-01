-- Completion: the LSP servers provide the candidates, this shows them.

return {
    {
        "saghen/blink.cmp",
        -- V2 is a breaking rewrite that also needs blink.lib, stay on stable.
        version = "1.*",
        dependencies = { "rafamadriz/friendly-snippets" },
        event = { "InsertEnter", "CmdlineEnter" },
        ---@module "blink.cmp"
        ---@type blink.cmp.Config
        opts = {
            keymap = {
                -- Enter accepts the highlighted item; <C-j>/<C-k> walk the
                -- list because zellij takes <C-n>/<C-p>.
                preset = "enter",
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
            },
            completion = {
                documentation = {
                    -- Show the full doc block next to the menu, not just the signature.
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            fuzzy = {
                implementation = "prefer_rust_with_warning",
            },
            signature = { enabled = true },
        },
    },
}
