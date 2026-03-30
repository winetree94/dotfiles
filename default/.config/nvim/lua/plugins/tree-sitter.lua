local pack = require("configs.pack")

pack.now(function()
  pack.add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "main",
  })

  -- for mdx support
  pack.add({
    source = "davidmh/mdx.nvim",
    checkout = "main",
  })

  -- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
  require("nvim-treesitter").install({
    "lua",
    "astro",
    "javascript",
    "jsx",
    "typescript",
    "tsx",
    "markdown",
    "markdown_inline",
    "python",
  })

  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local ft = args.match
      local lang = vim.treesitter.language.get_lang(ft) or ft
      local ok = pcall(vim.treesitter.language.inspect, lang)
      if ok then
        vim.treesitter.start(args.buf, lang)
      end
    end,
  })
end)
