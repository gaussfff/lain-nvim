-- Entry point for the Neovim configuration.
-- Load order: options -> keymaps -> plugin manager (lazy.nvim).

require("config.options")
require("config.keymaps")
require("config.lazy")
