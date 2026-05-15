vim.pack.add({
  {
    src = "https://github.com/nvim-mini/mini.map",
    version = "stable",
  },
}, { confirm = false, load = false })

require("mini.map").setup({})

vim.keymap.set("n", "<Leader>mo", MiniMap.open, { desc = "Open MiniMap" })
vim.keymap.set("n", "<Leader>mc", MiniMap.close, { desc = "Close MiniMap" })
vim.keymap.set("n", "<Leader>mt", MiniMap.toggle, { desc = "Toggle MiniMap" })
