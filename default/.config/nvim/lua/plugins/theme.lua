local pack = require("configs.pack")

pack.now(function()
  pack.add({
    source = "EdenEast/nightfox.nvim",
  })
  vim.cmd.colorscheme("carbonfox")
end)
