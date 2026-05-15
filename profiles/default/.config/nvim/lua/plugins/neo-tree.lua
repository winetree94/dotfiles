vim.pack.add({
  {
    src = "https://github.com/nvim-lua/plenary.nvim",
  },
  {
    src = "https://github.com/MunifTanjim/nui.nvim",
  },
  {
    src = "https://github.com/nvim-tree/nvim-web-devicons",
  },
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    version = "v3.x",
  },
}, { confirm = false, load = false })

require("neo-tree").setup({
  filesystem = {
    follow_current_file = {
      enabled = true,
      leave_dirs_open = true,
    },
    use_libuv_file_watcher = true,
  },
})
vim.keymap.set("n", "<leader>nt", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
vim.keymap.set("n", "<leader>nr", ":Neotree reveal<CR>", { desc = "Reveal buffer" })
vim.keymap.set("n", "<leader>nb", ":Neotree toggle show buffers right<CR>", { desc = "Toggle buffers panel" })
-- vim.keymap.set("n", "<leader>ns", ":Neotree float git_status<CR>", { desc = "Float git status" })
