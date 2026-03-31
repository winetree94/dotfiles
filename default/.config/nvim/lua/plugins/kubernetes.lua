vim.pack.add({
  {
    src = "https://github.com/nvim-lua/plenary.nvim",
  },
  {
    src = "https://github.com/cwrau/yaml-schema-detect.nvim",
  },
}, { confirm = false, load = false })

require("yaml-schema-detect").setup({
  keymap = {
    refresh = "<leader>yr",
    cleanup = "<leader>yc",
    info = "<leader>yi",
  },
})
