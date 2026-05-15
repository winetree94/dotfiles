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

-- Prefer tmux's clipboard integration when inside tmux. Neovim 0.12 already
-- knows how to use `tmux load-buffer -w -` for copy and `refresh-client -l`
-- for paste. Over SSH without tmux, force OSC52.
if vim.env.TMUX then
  vim.g.clipboard = "tmux"
elseif vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  vim.g.clipboard = "osc52"
end

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
