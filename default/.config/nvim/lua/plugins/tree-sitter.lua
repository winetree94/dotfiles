vim.pack.add({
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
  },
  {
    src = "https://github.com/davidmh/mdx.nvim",
    version = "main",
  },
}, { confirm = false, load = false })

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
