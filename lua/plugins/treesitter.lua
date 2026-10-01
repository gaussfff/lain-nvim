-- Syntax: Treesitter parsers for highlighting and indentation.
--
-- The main branch is a rewrite: it only installs parsers and queries, while
-- highlighting is switched on per buffer through Neovim's own API. Folding is
-- left alone here because nvim-ufo owns it.

local parsers = {
    "rust",
    "elixir",
    "heex",
    "eex",
    "typescript",
    "tsx",
    "javascript",
    "vue",
    "svelte",
    "css",
    "html",
    -- go.mod, go.sum and go.work are separate grammars, and Neovim
    -- already detects all three as their own filetypes.
    "go",
    "gomod",
    "gosum",
    "gowork",
    "sql",
    "lua",
    "bash",
    "fish",
    "json",
    "yaml",
    "toml",
    "ini",
    "properties",
    -- required by noice.nvim
    "vim",
    "vimdoc",
    "regex",
    "markdown",
    "markdown_inline",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false, -- upstream states the plugin does not support lazy loading
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install(parsers)

            -- There is no "conf" grammar. Most .conf files are key=value with
            -- comments, which the properties grammar covers, including typed
            -- values. Use "ini" instead if yours are section-heavy.
            vim.treesitter.language.register("properties", "conf")

            -- Highlighting is no longer automatic; start it for every filetype
            -- that has a parser available.
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                    if lang and pcall(vim.treesitter.language.add, lang) then
                        pcall(vim.treesitter.start, args.buf, lang)
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
}
