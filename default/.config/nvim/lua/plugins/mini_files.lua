-- File explorer
MiniDeps.later(function()
	MiniDeps.add({ source = "nvim-mini/mini.files", checkout = "stable" })
	require("mini.files").setup({
		windows = {
			preview = true,
			width_preview = 40,
		},
	})

	vim.keymap.set("n", "<Leader>fr", function()
		MiniFiles.open()
	end, { desc = "File explorer (Root)" })

	vim.keymap.set("n", "<Leader>fc", function()
		local buf_name = vim.api.nvim_buf_get_name(0)
		if buf_name ~= "" and vim.uv.fs_stat(buf_name) then
			MiniFiles.open(buf_name)
		else
			MiniFiles.open()
		end
	end, { desc = "File explorer (Current)" })
end)
