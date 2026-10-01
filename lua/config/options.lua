-- General editor options. `vim.opt` sets Neovim settings.
-- Set leader keys before anything else so plugin mappings pick them up.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- UI
opt.number = true -- show line numbers
opt.relativenumber = true -- relative numbers for easy motions
opt.cursorline = true -- highlight the current line
opt.signcolumn = "yes" -- always show the sign column (no layout shift)
opt.wrap = false -- don't wrap long lines
opt.scrolloff = 8 -- keep 8 lines visible above/below the cursor
opt.termguicolors = true -- 24-bit colors

-- Indentation
opt.expandtab = true -- spaces instead of tabs
opt.shiftwidth = 4 -- size of an indent
opt.tabstop = 4 -- width a literal tab is displayed as
opt.softtabstop = 4 -- how far <Tab> and <BS> move in insert mode
opt.smartindent = true -- smart autoindenting on new lines

-- Search
opt.ignorecase = true -- ignore case in search...
opt.smartcase = true -- ...unless the query has uppercase
opt.hlsearch = false -- don't keep matches highlighted
opt.incsearch = true -- show matches as you type

-- Behavior
opt.mouse = "a" -- enable mouse in all modes
-- Nvim defaults to popup_setpos, so a right-click (or a two-finger tap on a
-- trackpad) pops a context menu over the buffer. Extend a selection instead.
opt.mousemodel = "extend"
opt.clipboard = "unnamedplus" -- use the system clipboard
opt.undofile = true -- persistent undo history
opt.swapfile = false -- no swap files
opt.updatetime = 250 -- faster CursorHold / diagnostics
opt.splitright = true -- vertical splits open to the right
opt.splitbelow = true -- horizontal splits open below

-- Filetypes
-- GitHub Linguist counts .pgsql as PostgreSQL; Neovim leaves it untyped.
vim.filetype.add({ extension = { pgsql = "sql" } })
-- The built-in SQL ftplugin maps a dozen insert-mode <C-c> chords, so leaving
-- insert with <C-c> stalls for timeoutlen. Completion comes from the LSP.
vim.g.omni_sql_no_default_maps = 1
