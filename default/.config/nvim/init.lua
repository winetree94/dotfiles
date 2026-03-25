-- Bootstrap mini.deps
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.deps'

if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing mini.deps..." | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/nvim-mini/mini.deps', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.deps | helptags ALL')
  vim.cmd('echo "Done!" | redraw')
end

require('mini.deps').setup({
  path = { package = path_package }
})

-- Load base options and keymaps
-- require('config.options')

-- Require all .lua files in a directory under lua/
local function load_directory(path)
  local dir = vim.fn.stdpath('config') .. '/lua/' .. path
  local module_prefix = path:gsub('/', '.')
  for _, file in ipairs(vim.fn.readdir(dir)) do
    if file:match('%.lua$') then
      require(module_prefix .. '.' .. file:gsub('%.lua$', ''))
    end
  end
end

-- Load all plugins
load_directory('configs')
load_directory('plugins')

