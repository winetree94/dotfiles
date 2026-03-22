MiniDeps.later(function()
	MiniDeps.add({
		source = "lewis6991/gitsigns.nvim",
	})

	require("gitsigns").setup({
		auto_attach = true,
		current_line_blame = true,
		numhl = true,
		linehl = true,
		word_diff = false,
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end, { desc = "Next hunk" })

			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, { desc = "Previous hunk" })

			-- Actions
			map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
			map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk" })

			map("v", "<leader>gs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Stage hunk" })

			map("v", "<leader>gr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Reset hunk" })

			map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage buffer" })
			map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset buffer" })
			map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
			map("n", "<leader>gi", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })

			map("n", "<leader>gb", function()
				gitsigns.blame_line({ full = true })
			end, { desc = "Blame line (full)" })

			map("n", "<leader>gd", gitsigns.diffthis, { desc = "Diff this" })

			map("n", "<leader>gD", function()
				gitsigns.diffthis("~")
			end, { desc = "Diff this (~)" })

			map("n", "<leader>gQ", function()
				gitsigns.setqflist("all")
			end, { desc = "Send all hunks to quickfix" })
			map("n", "<leader>gq", gitsigns.setqflist, { desc = "Send hunks to quickfix" })

			-- Toggles
			map("n", "<leader>gtb", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
			map("n", "<leader>gtw", gitsigns.toggle_word_diff, { desc = "Toggle word diff" })

			-- Text object
			map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "Select hunk" })
		end,
	})
end)
