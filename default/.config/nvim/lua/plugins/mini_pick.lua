-- Fuzzy Finder
MiniDeps.later(function()
  MiniDeps.add({ source = "nvim-mini/mini.pick", checkout = "stable" })
  require("mini.pick").setup({
    -- mappings = {
    -- 	sys_paste = {
    -- 		char = "<C-v>",
    -- 		func = function()
    -- 			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>+", true, true, true), "n", true)
    -- 		end,
    -- 	},
    -- },
  })

  -- Leader based keymaps
  vim.keymap.set("n", "<Leader>pc", MiniExtra.pickers.commands, { desc = "Commands" })
  -- vim.keymap.set("n", "<Leader>pe", MiniExtra.pickers.explorer, { desc = "Explorer" })
  vim.keymap.set("n", "<Leader>pf", MiniPick.builtin.files, { desc = "Find files" })
  vim.keymap.set("n", "<Leader>pg", MiniPick.builtin.grep_live, { desc = "Live grep" })
  vim.keymap.set("n", "<Leader>pk", MiniExtra.pickers.keymaps, { desc = "Keymaps" })
  vim.keymap.set("n", "<Leader>pb", MiniPick.builtin.buffers, { desc = "Buffers" })
  vim.keymap.set("n", "<Leader>ph", MiniPick.builtin.help, { desc = "Help" })
  vim.keymap.set("n", "<Leader>pr", MiniExtra.pickers.oldfiles, { desc = "Recent files" })
  vim.keymap.set("n", "<Leader>pd", MiniExtra.pickers.diagnostic, { desc = "Diagnostics" })
end)
