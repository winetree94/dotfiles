-- Base options configuration (preserve default keymaps)

local opt = vim.opt

-- Tab/Indent
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false

-- Editing
opt.wrap = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true

-- File
opt.undofile = true
opt.swapfile = false
opt.backup = false

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Clipboard (sync with system clipboard)
opt.clipboard = "unnamedplus"

-- Leader key configuration
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clear search highlight with Escape
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>")

vim.o.autoread = true

-- LSP
vim.keymap.set("n", "grf", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer (LSP)" })

vim.keymap.set("n", "grd", function()
	vim.diagnostic.setloclist()
end, { desc = "Show diagnostics" })

