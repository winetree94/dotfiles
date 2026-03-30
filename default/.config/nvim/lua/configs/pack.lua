local M = {}

local snapshot = {}
local snapshot_path = vim.fn.stdpath("config") .. "/mini-deps-snap"
if vim.uv.fs_stat(snapshot_path) then
  snapshot = dofile(snapshot_path)
end

local function normalize_source(src)
  if src:match("^https?://") or src:match("^%a[%w+.-]*:") then
    return src
  end

  return "https://github.com/" .. src
end

local function plugin_name(src)
  local name = src:gsub("/+$", ""):match("([^/]+)$") or src
  return name:gsub("%.git$", "")
end

local function normalize_spec(spec)
  if type(spec) == "string" then
    spec = { src = spec }
  else
    spec = vim.deepcopy(spec)
  end

  spec.src = normalize_source(spec.src or spec.source)
  spec.source = nil

  if not spec.name then
    spec.name = plugin_name(spec.src)
  end

  if spec.checkout ~= nil and spec.version == nil then
    spec.version = spec.checkout
  end
  spec.checkout = nil

  if spec.version == nil and snapshot[spec.name] ~= nil then
    spec.version = snapshot[spec.name]
  end

  return spec
end

local function flatten_specs(specs, flattened)
  flattened = flattened or {}

  for _, spec in ipairs(specs) do
    local normalized = normalize_spec(spec)
    if normalized.depends ~= nil then
      flatten_specs(normalized.depends, flattened)
      normalized.depends = nil
    end
    table.insert(flattened, normalized)
  end

  return flattened
end

function M.add(specs, opts)
  if specs == nil then
    return
  end

  if specs.src ~= nil or specs.source ~= nil or type(specs) == "string" then
    specs = { specs }
  end

  vim.pack.add(flatten_specs(specs), opts or { load = false, confirm = false })
end

function M.now(fn)
  fn()
end

function M.later(fn)
  if vim.v.vim_did_enter == 1 then
    vim.schedule(fn)
    return
  end

  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(fn)
    end,
  })
end

return M
