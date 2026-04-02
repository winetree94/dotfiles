vim.pack.add({
  {
    src = "https://github.com/nvim-lua/plenary.nvim",
  },
  {
    src = "https://github.com/sindrets/diffview.nvim",
  },
  {
    src = "https://github.com/nvim-mini/mini.pick",
    version = "stable",
  },
  {
    src = "https://github.com/NeogitOrg/neogit",
    version = "master",
  },
}, { confirm = false })

local neogit = require("neogit")

neogit.setup({
  integrations = {
    diffview = true,
    mini_pick = true,
  },
})

vim.keymap.set("n", "<leader>gg", neogit.open, { desc = "Open Neogit UI" })
