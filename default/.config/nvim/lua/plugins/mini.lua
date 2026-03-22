local add, now = MiniDeps.add, MiniDeps.now

now(function()
  --------------- text editing
	add({ source = "nvim-mini/mini.ai", checkout = "stable" })
	require("mini.ai").setup()

	add({ source = "nvim-mini/mini.pairs", checkout = "stable" })
	require("mini.pairs").setup()

	add({ source = "nvim-mini/mini.move", checkout = "stable" })
	require("mini.move").setup()

  --------------- general workflow
	add({ source = "nvim-mini/mini.basics", checkout = "stable" })
	require("mini.basics").setup()

	add({ source = "nvim-mini/mini.bracketed", checkout = "stable" })
	require("mini.bracketed").setup()

	add({ source = "nvim-mini/mini.bufremove", checkout = "stable" })
	require("mini.bufremove").setup()

	add({ source = "nvim-mini/mini.cmdline", checkout = "stable" })
	require("mini.cmdline").setup()

  add({ source = 'nvim-mini/mini.extra', checkout = 'stable' })
  require('mini.extra').setup()

	add({ source = "nvim-mini/mini-git", checkout = "stable" })
	require("mini.git").setup()

	add({ source = "nvim-mini/mini.jump", checkout = "stable" })
	require("mini.jump").setup()

	add({ source = "nvim-mini/mini.jump2d", checkout = "stable" })
	require("mini.jump2d").setup()

  --------------- appearance
	add({ source = "nvim-mini/mini.cursorword", checkout = "stable" })
	require("mini.cursorword").setup()

	add({ source = "nvim-mini/mini.icons", checkout = "stable" })
	require("mini.icons").setup()

	add({ source = "nvim-mini/mini.indentscope", checkout = "stable" })
	require("mini.indentscope").setup()

	add({ source = "nvim-mini/mini.notify", checkout = "stable" })
	require("mini.notify").setup()

	add({ source = "nvim-mini/mini.statusline", checkout = "stable" })
	require("mini.statusline").setup()

	add({ source = "nvim-mini/mini.tabline", checkout = "stable" })
	require("mini.tabline").setup()

	add({ source = "nvim-mini/mini.trailspace", checkout = "stable" })
	require("mini.trailspace").setup()
end)
