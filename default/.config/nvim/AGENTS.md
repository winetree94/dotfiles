# AGENTS.md - Neovim Configuration

## Project Overview

Personal Neovim configuration in Lua targeting Neovim 0.11+. Uses **mini.deps**
(`nvim-mini/mini.nvim`) as plugin manager, with the mini.nvim ecosystem for editing,
navigation, and UI. Completion is handled by **blink.cmp**, git by **gitsigns.nvim** +
**neogit**, file browsing by **neo-tree.nvim** + **mini.files**.

## Directory Structure

```
init.lua                    # Entry point: bootstraps mini.deps, loads configs/ + plugins/
lua/
  configs/
    options.lua             # Neovim options, leader key, global keymaps
  plugins/
    blink.lua               # blink.cmp (completion engine)
    comments.lua            # ts-comments.nvim (context-aware commenting)
    gitsign.lua             # gitsigns.nvim (git signs, hunk actions, blame)
    kubernetes.lua          # yaml-schema-detect.nvim (Kubernetes YAML)
    lsp.lua                 # nvim-lspconfig + vim.lsp.enable() for all servers
    mason.lua               # mason.nvim + mason-tool-installer (auto-install)
    mini.lua                # Bulk mini.nvim modules (ai, pairs, move, icons, etc.)
    mini_clue.lua           # mini.clue (keybinding hints)
    mini_files.lua          # mini.files (file explorer)
    mini_hipatterns.lua     # mini.hipatterns (highlight TODO/FIXME/hex colors)
    mini_map.lua            # mini.map (code minimap)
    mini_pick.lua           # mini.pick + mini.extra (fuzzy finder)
    neo-tree.lua            # neo-tree.nvim (sidebar file tree)
    neogit.lua              # neogit (git porcelain UI)
    theme.lua               # nightfox.nvim (carbonfox colorscheme)
    tree-sitter.lua         # nvim-treesitter (syntax highlighting)
after/
  lsp/
    lua_ls.lua              # Per-server LSP config (Neovim 0.11+ convention)
```

## Build / Lint / Test Commands

No traditional build system or test suite. Validation is interactive.

```bash
# Validate config loads without errors
nvim --headless -c 'qall'

# Format ALL Lua files (config uses non-standard filename)
stylua --config-path .stylelua.toml .

# Format a single file
stylua --config-path .stylelua.toml lua/plugins/lsp.lua

# Lint all Lua files
luacheck lua/ init.lua

# Lint a single file
luacheck lua/plugins/blink.lua
```

**IMPORTANT:** StyLua config is `.stylelua.toml` (non-standard name). You MUST pass
`--config-path .stylelua.toml` every time. StyLua will NOT auto-discover it.

## Code Style Guidelines

### Language and Runtime

- **Language:** Lua (LuaJIT runtime)
- **Target:** Neovim 0.11+ (uses `vim.lsp.enable()` and `after/lsp/` convention)

### Formatting

- **Indentation:** 2 spaces (indent_width=2, indent_type=Spaces)
- **Formatter:** StyLua (config: `.stylelua.toml`)
- **Line width:** 120 (StyLua default)
- Always run `stylua --config-path .stylelua.toml <file>` after editing Lua files

### Strings and Quotes

- **Mixed convention:** some files use single quotes (`'`), others use double quotes (`"`).
  StyLua does not enforce quote style. **Match the existing style of the file you edit.**
- URL/path strings in `source` fields use double quotes consistently.

### Imports and Module Loading

- Plugin files are loaded for **side effects** -- they do NOT return a module table
- `init.lua` scans `lua/configs/*.lua` and `lua/plugins/*.lua` via `load_directory()`
- Use `MiniDeps.add()` to declare plugin dependencies
- Use `MiniDeps.now()` for UI-critical plugins (theme, treesitter, neo-tree, mini core)
- Use `MiniDeps.later()` for deferrable plugins (LSP, git, completion, pickers)
- Destructure when using multiple MiniDeps functions:
  ```lua
  local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
  ```
- For simple files, call `MiniDeps.add()` / `MiniDeps.later()` directly on the global

### Naming Conventions

- **Files:** Lowercase, short names (`lsp.lua`, `theme.lua`). Underscores for
  sub-modules (`mini_pick.lua`). Hyphens for plugin-named files (`neo-tree.lua`).
- **Variables:** `snake_case` for locals and parameters
- **Neovim API:** Always use `vim.*` namespace (`vim.opt`, `vim.g`, `vim.keymap`, `vim.api`)
- **Mini globals:** Used directly after setup -- `MiniDeps`, `MiniFiles`, `MiniPick`,
  `MiniExtra`, `MiniMap`

### Keymaps

- Use `vim.keymap.set()` with `desc` field on every keymap (enables mini.clue discovery)
- Leader key is `<Space>` (set in `lua/configs/options.lua`)
- Keymap group prefixes:
  - `<Leader>p` -- pick/search (mini.pick)
  - `<Leader>f` -- file explorer (mini.files)
  - `<Leader>m` -- minimap (mini.map)
  - `<Leader>n` -- neo-tree (sidebar tree)
  - `<Leader>g` -- git operations (gitsigns, neogit)
  - `<Leader>gt` -- git toggle options
  - `<Leader>y` -- YAML schema operations
  - `gr` prefix -- LSP operations (grn=rename, gra=action, grf=format, grd=diagnostics)

### Plugin File Patterns

Each file in `lua/plugins/` follows one of these patterns:

```lua
-- Pattern 1: Deferred plugin with config
MiniDeps.later(function()
  MiniDeps.add({ source = 'author/plugin-name' })
  require('plugin-name').setup({ ... })
  vim.keymap.set('n', '<Leader>x', some_fn, { desc = 'Description' })
end)

-- Pattern 2: Immediate plugin (UI-critical)
MiniDeps.now(function()
  MiniDeps.add({ source = 'author/plugin-name' })
  require('plugin-name').setup({ ... })
end)

-- Pattern 3: Destructured with separate add + now/later
local add, now = MiniDeps.add, MiniDeps.now
add({ source = 'author/plugin', depends = { 'dep/one' }, checkout = 'v1.0' })
now(function()
  require('plugin').setup({ ... })
end)
```

### Error Handling

- No explicit error handling -- Neovim surfaces errors at startup
- One exception: `tree-sitter.lua` uses `pcall(vim.treesitter.language.inspect, lang)`
  to gracefully skip missing parsers

### LSP Configuration

- All LSP servers enabled in `lua/plugins/lsp.lua` via `vim.lsp.enable({...})`
- Per-server config in `after/lsp/<server_name>.lua` returning `vim.lsp.Config` table
- Mason auto-installs all servers on startup (3s delay)
- Mason-managed tools: `lua-language-server`, `stylua`, `luacheck`,
  `yaml-language-server`, `vim-language-server`, `json-lsp`, `html-lsp`,
  `typescript-language-server`, `bash-language-server`, `eslint-lsp`, `biome`,
  `css-lsp`, `emmet-language-server`, `tailwindcss-language-server`,
  `astro-language-server`, `ansible-language-server`, `dockerfile-language-server`,
  `docker-language-server`, `docker-compose-language-service`,
  `gh-actions-language-server`, `helm-ls`

### Options Configuration

- `vim.opt` aliased to local `opt` in `lua/configs/options.lua`
- `vim.g` for global variables (leader key, netrw settings)
- Grouped with section comments (`-- Tab/Indent`, `-- UI`, `-- Search`, etc.)

## Configuration Files

| File | Purpose |
|------|---------|
| `.stylelua.toml` | StyLua config (non-standard name -- always use `--config-path`) |
| `.luarc.json` | lua_ls config (LuaJIT runtime, vim global, workspace libraries) |

## Known Issues

- `.stylelua.toml` is a non-standard filename. StyLua requires explicit `--config-path`.
- `MiniDeps` and other Mini globals are not in `.luarc.json` globals list; lua_ls may warn.
- `after/lsp/lua_ls.lua` sets runtime to "Lua 5.4" while `.luarc.json` sets "LuaJIT" --
  these serve different purposes (LSP server config vs editor tooling) but could confuse.
