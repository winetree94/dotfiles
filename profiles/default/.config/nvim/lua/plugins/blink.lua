vim.pack.add({
  {
    src = "https://github.com/rafamadriz/friendly-snippets",
  },
  {
    src = "https://github.com/saghen/blink.cmp",
    version = "v1.9.1",
  },
}, { confirm = false, load = false })

require("blink.cmp").setup({
  keymap = { preset = "default" },

  appearance = {
    nerd_font_variant = "mono",
  },

  completion = {
    documentation = { auto_show = true },
  },

  signature = {
    enabled = true,
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  fuzzy = { implementation = "prefer_rust" },
})
