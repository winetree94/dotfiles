MiniDeps.later(function()
	MiniDeps.add({
		source = "NeogitOrg/neogit",
		depends = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-mini/mini.pick",
		},
	})

	local neogit = require("neogit")

	neogit.setup({
		integrations = {
			diffview = true,
			mini_pick = true,
		},
	})

	vim.keymap.set("n", "<leader>gg", neogit.open, { desc = "Open Neogit UI" })
end)
