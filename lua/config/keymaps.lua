-- Core keymaps. Plugin-specific mappings live with their plugin specs.
local map = vim.keymap.set

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window navigation lives in lua/plugins/windows.lua: smart-splits.nvim owns
-- <C-hjkl> so the same keys cross into zellij panes.

-- Go to definition. Neovim 0.11 ships gr* for references, implementation and
-- type, but leaves definition unmapped; gd and gD fall back to their builtin
-- meaning when no language server is attached.
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })

-- Move selected lines up/down in visual mode.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the cursor centered when jumping.
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- Save / quit.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })

-- Cyrillic layout: silence, not errors.
--
-- With a Russian or Ukrainian layout on, these keys mean nothing to Vim, so
-- every press produces a beep and an E-message. Mapping them to <Nop> keeps
-- normal, visual and operator-pending modes quiet. Insert and command-line
-- modes are untouched, so typing still works.
for _, char in ipairs({
    "а",
    "б",
    "в",
    "г",
    "д",
    "е",
    "ж",
    "з",
    "и",
    "й",
    "к",
    "л",
    "м",
    "н",
    "о",
    "п",
    "р",
    "с",
    "т",
    "у",
    "ф",
    "х",
    "ц",
    "ч",
    "ш",
    "щ",
    "ъ",
    "ы",
    "ь",
    "э",
    "ю",
    "я",
    "ё",
    "є",
    "і",
    "ї",
    "ґ",
    "А",
    "Б",
    "В",
    "Г",
    "Д",
    "Е",
    "Ж",
    "З",
    "И",
    "Й",
    "К",
    "Л",
    "М",
    "Н",
    "О",
    "П",
    "Р",
    "С",
    "Т",
    "У",
    "Ф",
    "Х",
    "Ц",
    "Ч",
    "Ш",
    "Щ",
    "Ъ",
    "Ы",
    "Ь",
    "Э",
    "Ю",
    "Я",
    "Ё",
    "Є",
    "І",
    "Ї",
    "Ґ",
    "'",
}) do
    map({ "n", "x", "o" }, char, "<Nop>")
end
