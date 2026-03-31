vim.pack.add({
  {
    src = "https://github.com/neovim/nvim-lspconfig",
  },
}, { confirm = false, load = false })

vim.lsp.enable({
  "gh_actions_ls",
  "lua_ls",
  "stylua",
  "ts_ls",
  "biome",
  "eslint",
  "bashls",
  "tailwindcss",
  "astro",
  "yamlls",
  "vimls",
  "jsonls",
  "html",
  "emmet_language_server",
  "cssls",
  "ansiblels",
  "dockerls",
  "docker_language_server",
  "docker_compose_language_service",
  "helm_ls",
  "pylsp",
})
