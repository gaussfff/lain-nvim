-- Rust: rustaceanvim configures rust-analyzer itself and adds Rust-only
-- commands on top of it. lsp.lua must not set up rust_analyzer as well.
--

return {
    {
        "mrcjkb/rustaceanvim",
        version = "^9",
        lazy = false, -- it is a filetype plugin, lazy loading would break it
        init = function()
            vim.g.rustaceanvim = {
                server = {
                    default_settings = {
                        ["rust-analyzer"] = {
                            -- Diagnostics from clippy instead of plain cargo check.
                            check = { command = "clippy" },
                        },
                    },
                },
            }
        end,
        keys = {
            {
                "<leader>ra",
                "<cmd>RustLsp codeAction<cr>",
                ft = "rust",
                desc = "Rust: grouped code actions",
            },
            { "<leader>rr", "<cmd>RustLsp runnables<cr>", ft = "rust", desc = "Rust: runnables" },
            { "<leader>rt", "<cmd>RustLsp testables<cr>", ft = "rust", desc = "Rust: testables" },
            {
                "<leader>rm",
                "<cmd>RustLsp expandMacro<cr>",
                ft = "rust",
                desc = "Rust: expand macro",
            },
            {
                "<leader>rp",
                "<cmd>RustLsp parentModule<cr>",
                ft = "rust",
                desc = "Rust: parent module",
            },
            {
                "<leader>rc",
                "<cmd>RustLsp openCargo<cr>",
                ft = "rust",
                desc = "Rust: open Cargo.toml",
            },
            {
                "<leader>re",
                "<cmd>RustLsp explainError<cr>",
                ft = "rust",
                desc = "Rust: explain error",
            },
            {
                "<leader>rd",
                "<cmd>RustLsp renderDiagnostic<cr>",
                ft = "rust",
                desc = "Rust: render diagnostic",
            },
        },
    },
}
