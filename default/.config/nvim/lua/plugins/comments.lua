vim.pack.add({
  {
    src = "https://github.com/folke/ts-comments.nvim",
  },
}, { confirm = false, load = false })

require("ts-comments").setup()
