MiniDeps.later(function()
	MiniDeps.add({
		source = "https://github.com/mason-org/mason.nvim",
	})

	require("mason").setup()

	MiniDeps.add({
		source = "WhoIsSethDaniel/mason-tool-installer.nvim",
	})

	require("mason-tool-installer").setup({

		-- a list of all tools you want to ensure are installed upon
		-- start
		ensure_installed = {
			-- lsp
			"lua-language-server",
			"stylua",
			"luacheck",
			"yaml-language-server",
			"vim-language-server",
			"json-lsp",
			"html-lsp",
			"typescript-language-server",
			"bash-language-server",
			"eslint-lsp",
			"biome",
			"css-lsp",
			"emmet-language-server",
			"tailwindcss-language-server",
			"astro-language-server",
			"ansible-language-server",
			"dockerfile-language-server",
			"docker-language-server",
			"docker-compose-language-service",
      "gh-actions-language-server",
      "helm-ls",
      "python-lsp-server"
		},

		-- if set to true this will check each tool for updates. If updates
		-- are available the tool will be updated. This setting does not
		-- affect :MasonToolsUpdate or :MasonToolsInstall.
		-- Default: false
		auto_update = true,

		-- automatically install / update on startup. If set to false nothing
		-- will happen on startup. You can use :MasonToolsInstall or
		-- :MasonToolsUpdate to install tools and check for updates.
		-- Default: true
		run_on_start = true,

		-- set a delay (in ms) before the installation starts. This is only
		-- effective if run_on_start is set to true.
		-- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
		-- Default: 0
		start_delay = 3000, -- 3 second delay
	})
end)
