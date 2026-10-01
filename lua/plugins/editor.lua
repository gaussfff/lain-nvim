-- Editor: file management.

return {
    {
        "stevearc/oil.nvim",
        opts = {
            delete_to_trash = true,
            -- Skip the confirmation popup for edits that delete nothing.
            skip_confirm_for_simple_edits = true,
            view_options = {
                -- Dotfiles are shown by default; "g." still toggles them off.
                show_hidden = true,
                -- Oil counts ".." as a dotfile, but "-" already goes up.
                is_always_hidden = function(name)
                    return name == ".."
                end,
            },
            columns = {
                "icon",
                "permissions",
                "size",
                "mtime",
            },
            -- Zellij owns Ctrl+p, Ctrl+s and Ctrl+t, and Ctrl+h/l belong to
            -- window navigation, so those actions moved to the leader key.
            keymaps = {
                ["<C-p>"] = false,
                ["<C-s>"] = false,
                ["<C-t>"] = false,
                ["<C-h>"] = false,
                ["<C-l>"] = false,
                ["<leader>r"] = { "actions.refresh", mode = "n" },
                ["<leader>p"] = { "actions.preview", mode = "n" },
                ["<leader>v"] = { "actions.select", opts = { vertical = true }, mode = "n" },
                ["<leader>x"] = { "actions.select", opts = { horizontal = true }, mode = "n" },
                ["<leader>t"] = { "actions.select", opts = { tab = true }, mode = "n" },
                ["<leader>d"] = { "actions.preview_scroll_down", mode = "n" },
                ["<leader>u"] = { "actions.preview_scroll_up", mode = "n" },
            },
            lsp_file_methods = {
                enabled = true,
                -- Only save buffers that had no unsaved changes of their own.
                autosave_changes = "unmodified",
            },
            confirmation = {
                border = "rounded",
            },
            progress = {
                minimized_border = "rounded",
            },
        },
        -- Oil only maps keys inside its own buffers, so opening it needs a global one.
        keys = {
            { "-", "<cmd>Oil<cr>", desc = "Open parent directory in oil" },
        },
        dependencies = { "nvim-mini/mini.icons" },
        init = function()
            -- :Ssh relay-stage /etc/sftpgo/sftpgo.conf
            -- A trailing slash lists the directory, anything else opens the
            -- file itself. The host argument completes from /etc/hosts and
            -- ~/.ssh/config.
            vim.api.nvim_create_user_command("Ssh", function(args)
                require("util.ssh").open(args.fargs[1], args.fargs[2])
            end, {
                nargs = "+",
                desc = "Open a remote path through oil",
                complete = function(lead, line)
                    -- Only the first argument is a host; the rest is a path.
                    if line:match("^%s*Ssh%s+%S+%s") then
                        return {}
                    end
                    return vim.tbl_filter(function(host)
                        return host:sub(1, #lead) == lead
                    end, require("util.ssh").hosts())
                end,
            })
        end,
        lazy = false,
    },
}
