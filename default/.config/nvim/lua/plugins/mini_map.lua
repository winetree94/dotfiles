MiniDeps.later(function()
	MiniDeps.add({
		source = "nvim-mini/mini.map",
		checkout = "stable",
	})
  require('mini.map').setup({})

  vim.keymap.set('n', '<Leader>mo', MiniMap.open, { desc = 'Open MiniMap' })
  vim.keymap.set('n', '<Leader>mc', MiniMap.close, { desc = 'Close MiniMap' })
  vim.keymap.set('n', '<Leader>mt', MiniMap.toggle, { desc = 'Toggle MiniMap' })
end)
