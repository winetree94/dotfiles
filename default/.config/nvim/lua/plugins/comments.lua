local pack = require("configs.pack")

pack.later(function()
  pack.add({
    source = "folke/ts-comments.nvim",
  })

  require("ts-comments").setup()
end)
