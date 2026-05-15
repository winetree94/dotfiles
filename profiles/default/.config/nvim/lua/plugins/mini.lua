vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.ai", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.pairs", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.move", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.basics", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.bracketed", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.bufremove", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.cmdline", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.extra", version = "stable" },
  { src = "https://github.com/nvim-mini/mini-git", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.jump", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.jump2d", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.cursorword", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.icons", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.indentscope", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.notify", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.statusline", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.tabline", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.trailspace", version = "stable" },
}, { confirm = false, load = false })

--------------- text editing
require("mini.ai").setup()
require("mini.pairs").setup()
require("mini.move").setup()

--------------- general workflow
require("mini.basics").setup()
require("mini.bracketed").setup()
require("mini.bufremove").setup()
require("mini.cmdline").setup()
require("mini.extra").setup()
require("mini.git").setup()
require("mini.jump").setup()
require("mini.jump2d").setup()

--------------- appearance
require("mini.cursorword").setup()
require("mini.icons").setup()
require("mini.indentscope").setup()
require("mini.notify").setup()
require("mini.statusline").setup()
require("mini.tabline").setup()
require("mini.trailspace").setup()
