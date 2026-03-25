local add, later = MiniDeps.add, MiniDeps.later

add({
  source = "saghen/blink.cmp",
  depends = { "rafamadriz/friendly-snippets" },
  checkout = "v1.9.1",
})

later(function()
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
end)

