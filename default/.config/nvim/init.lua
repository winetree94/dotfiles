local data_site = vim.fn.stdpath("data") .. "/site"

if not vim.list_contains(vim.opt.packpath:get(), data_site) then
  vim.opt.packpath:append(data_site)
end

-- Require all .lua files in a directory under lua/
local function load_directory(path)
  local dir = vim.fn.stdpath("config") .. "/lua/" .. path
  local module_prefix = path:gsub("/", ".")
  for _, file in ipairs(vim.fn.readdir(dir)) do
    if file:match("%.lua$") then
      require(module_prefix .. "." .. file:gsub("%.lua$", ""))
    end
  end
end

load_directory("configs")
load_directory("plugins")
