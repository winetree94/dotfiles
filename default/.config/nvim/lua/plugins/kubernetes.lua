MiniDeps.later(function()
	MiniDeps.add({
		source = "cwrau/yaml-schema-detect.nvim",
		depends = {
			"nvim-lua/plenary.nvim",
		},
	})

	require("yaml-schema-detect").setup({
		keymap = {
			refresh = "<leader>yr",
			cleanup = "<leader>yc",
			info = "<leader>yi",
		},
	})
end)
