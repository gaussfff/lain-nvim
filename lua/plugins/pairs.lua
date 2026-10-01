-- Pairs: closes brackets and quotes while typing.

return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            -- Ask treesitter what node the cursor is in before adding a pair,
            -- so an apostrophe inside a string stays a single character.
            check_ts = true,
            ts_config = {
                lua = { "string" },
                javascript = { "template_string" },
            },
            -- <M-e> wraps the word after the cursor in the pair being typed.
            fast_wrap = {},
        },
    },
}
