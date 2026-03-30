local pack = require("configs.pack")

pack.later(function()
  pack.add({
    source = "cwrau/yaml-schema-detect.nvim",
    depends = {
      "nvim-lua/plenary.nvim",
    },
  })

  require("yaml-schema-detect").setup({
    keymap = {
      refresh = "<leader>yr",
      cleanup = "<leader>yc",
      info = "<leader>yi",
    },
  })
end)
