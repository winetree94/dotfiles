local pack = require("configs.pack")

pack.now(function()
  --------------- text editing
  pack.add({ source = "nvim-mini/mini.ai", checkout = "stable" })
  require("mini.ai").setup()

  pack.add({ source = "nvim-mini/mini.pairs", checkout = "stable" })
  require("mini.pairs").setup()

  pack.add({ source = "nvim-mini/mini.move", checkout = "stable" })
  require("mini.move").setup()

  --------------- general workflow
  pack.add({ source = "nvim-mini/mini.basics", checkout = "stable" })
  require("mini.basics").setup()

  pack.add({ source = "nvim-mini/mini.bracketed", checkout = "stable" })
  require("mini.bracketed").setup()

  pack.add({ source = "nvim-mini/mini.bufremove", checkout = "stable" })
  require("mini.bufremove").setup()

  pack.add({ source = "nvim-mini/mini.cmdline", checkout = "stable" })
  require("mini.cmdline").setup()

  pack.add({ source = 'nvim-mini/mini.extra', checkout = 'stable' })
  require('mini.extra').setup()

  pack.add({ source = "nvim-mini/mini-git", checkout = "stable" })
  require("mini.git").setup()

  pack.add({ source = "nvim-mini/mini.jump", checkout = "stable" })
  require("mini.jump").setup()

  pack.add({ source = "nvim-mini/mini.jump2d", checkout = "stable" })
  require("mini.jump2d").setup()

  --------------- appearance
  pack.add({ source = "nvim-mini/mini.cursorword", checkout = "stable" })
  require("mini.cursorword").setup()

  pack.add({ source = "nvim-mini/mini.icons", checkout = "stable" })
  require("mini.icons").setup()

  pack.add({ source = "nvim-mini/mini.indentscope", checkout = "stable" })
  require("mini.indentscope").setup()

  pack.add({ source = "nvim-mini/mini.notify", checkout = "stable" })
  require("mini.notify").setup()

  pack.add({ source = "nvim-mini/mini.statusline", checkout = "stable" })
  require("mini.statusline").setup()

  pack.add({ source = "nvim-mini/mini.tabline", checkout = "stable" })
  require("mini.tabline").setup()

  pack.add({ source = "nvim-mini/mini.trailspace", checkout = "stable" })
  require("mini.trailspace").setup()
end)
