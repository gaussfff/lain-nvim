-- Dashboard: the start screen shown when Neovim opens without a file.

return {
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        opts = {
            theme = "doom",
            config = {
                -- Blank lines are part of the art: two on top keep it off the
                -- ceiling, three below separate it from the list. All lines are
                -- padded to the same width because the theme centres each one
                -- on its own.
                header = {
                    "",
                    "",
                    "⠀⠀⠀⠀⠀⠀⣀⣤⠴⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠓⠦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⠀⠀⠀⠀⣠⠎⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠓⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⠀⠀⢀⡞⠁⠀⠀⠀⠀⠀⢀⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⠀⣼⠀⠀⠀⠀⠰⠦⠤⣤⣀⣈⣉⣉⣛⣒⠶⠦⠤⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⠀⡇⠀⠀⠀⠀⠀⡤⠴⠒⠒⠶⢤⣄⣀⡉⠉⠓⠦⣤⣀⣈⣉⣓⠲⢤⣀⡀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠙⠓⠒⠶⠤⣤⣀⣉⣙⣒⠦⢭⣙⡒⠦⣄⠈⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⢸⠀⠀⠀⠀⢠⠴⠖⠒⠒⠲⠶⠦⠤⢄⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠓⠲⠉⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⣼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⡇⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⡀⠀⠳⣄⠀⠀⠀⠀⠀⠀⣠⠴⠒⠒⠒⠲⠤⣄⡀⠀⠀⠀⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⡇⠀⠀⠀⠀⠀⠀⠀⠀⢧⣽⣿⣿⡛⢮⣷⠀⡶⠀⠀⢸⣀⡤⢴⠀⠀⠀⠀⠀⠙⢦⠀⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⣧⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠙⠛⠋⠀⢀⡇⠀⠀⡿⣴⠚⣿⣿⣿⡟⣦⠀⠀⠀⠀⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠃⠀⢀⡇⠈⠓⠻⠿⠿⠟⠁⠀⠀⠀⢰⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀ AH SHIT, HERE WE GO AGAIN",
                    "⡏⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠋⠀⠀⠀⠘⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⠤⠴⠊⣹                          ",
                    "⣧⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⠀⠀⠀⠀⠀⢸⣧⠀⠀⠀⠀⠀⠀⠀⠀⡾⠁⠀⠀⠀⠀⠀⣀⣤⠤⠴⠞⠉⠀⠀⠀⣴⠚⠑                          ",
                    "⡏⣽⣇⣶⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠛⠉⠳⡶⠟⠀⠀⠀⠀⠀⠀⠀⠀⢰⡧⠶⠶⠒⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⢾⠀⠀                          ",
                    "⡷⣿⣽⣿⣺⣧⣄⠀⠀⠀⠀⠀⠀⣠⠀⣶⠀⢀⡶⣤⡄⢢⡀⠀⠀⠀⠀⠀⣤⣽⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢳⡀                          ",
                    "⡇⣯⡏⣿⣾⣿⣯⡁⠀⡀⡾⠀⣶⡟⠀⣻⣤⣤⣼⣽⣧⠀⢿⣆⠀⠀⠀⠀⣹⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡴⠖⠒⠶⠾⠷                          ",
                    "⡇⣇⠴⣿⣯⡽⠇⢻⠲⣿⡧⠘⢩⣭⣿⣿⣿⣿⣿⣿⣿⣧⠀⡛⣆⠐⣦⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠁⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⠀⠀⠙⣿⣷⣼⠚⣆⣯⠀⠀⠸⣟⣿⣿⣿⣿⣿⣿⣿⡏⠘⣿⣼⢦⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠖⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⠀⠀⠀⠸⣿⣿⣦⠀⡀⠀⠀⠀⠙⢎⠛⠿⠿⢿⣿⡿⠀⢸⣻⣻⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⠀⠀⠀⠀⠘⠯⢿⣿⣃⠀⠀⠀⠀⠀⠙⠲⠶⠶⠛⠁⢀⢸⡿⠃⠈⠁⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⠀⠀⠀⠀⠀⠀⠾⣿⠻⣧⠀⠀⡀⠀⠀⠀⠀⠀⢠⢄⣼⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⡇⠀⠀⠀⠀⠀⠀⠀⠘⠛⠛⣷⣾⣧⣽⣷⣤⣴⣷⡟⠩⠟⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⣒⡋⢙⢛⢿⢉⡽⠯⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⠖⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                          ",
                    "",
                    "",
                    "",
                },
                -- The doom theme always inserts a blank line after an entry
                -- (doom.lua:38); there is no option for it.
                center = {
                    {
                        icon = "  ",
                        desc = "Open current directory",
                        key = "e",
                        key_format = " %s",
                        action = "Oil",
                    },
                    {
                        icon = "  ",
                        desc = "New file",
                        key = "n",
                        key_format = " %s",
                        action = "enew",
                    },
                    {
                        icon = "  ",
                        desc = "Plugins",
                        key = "l",
                        key_format = " %s",
                        action = "Lazy",
                    },
                    {
                        icon = "  ",
                        desc = "Language servers",
                        key = "m",
                        key_format = " %s",
                        action = "Mason",
                    },
                    {
                        icon = "  ",
                        desc = "Config",
                        key = "c",
                        key_format = " %s",
                        action = "edit " .. vim.fn.stdpath("config") .. "/init.lua",
                    },
                    {
                        icon = "  ",
                        desc = "Quit",
                        key = "q",
                        key_format = " %s",
                        action = "qa",
                    },
                },
                footer = function()
                    local stats = require("lazy").stats()
                    return {
                        "",
                        ("%d plugins in %.0f ms"):format(stats.loaded, stats.startuptime),
                    }
                end,
            },
        },
    },
}
