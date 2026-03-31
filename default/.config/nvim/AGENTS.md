# Repository Guidelines

## Project Structure & Module Organization

This repository is a personal Neovim configuration for Neovim 0.12+ written in Lua. `init.lua` is the entry point and loads files from `lua/configs/` and `lua/plugins/`. Core editor settings live in `lua/configs/options.lua`; plugins are managed directly from the plugin files with `vim.pack.add()`. Plugin setup is split into focused files such as `lua/plugins/lsp.lua`, `lua/plugins/blink.lua`, and `lua/plugins/neo-tree.lua`. Per-server LSP overrides belong in `after/lsp/` and should return a `vim.lsp.Config` table.

## Build, Test, and Development Commands

Use headless Neovim to validate startup:

```bash
nvim --headless -c 'qall'
```

Format Lua with the repository’s non-standard StyLua config:

```bash
stylua --config-path .stylelua.toml .
stylua --config-path .stylelua.toml lua/plugins/lsp.lua
```

Lint with Luacheck:

```bash
luacheck lua/ init.lua
luacheck lua/plugins/blink.lua
```

## Coding Style & Naming Conventions

Use 2-space indentation and keep lines within normal StyLua defaults. Match the existing quote style in the file you edit. File names are lowercase; use underscores for grouped modules like `mini_pick.lua` and hyphens for plugin-named files like `neo-tree.lua`. Prefer `vim.*` APIs, `snake_case` locals, and `vim.keymap.set()` with a `desc` on every mapping. Plugin files are loaded for side effects and normally do not return module tables.

## Testing Guidelines

There is no formal automated test suite. The required baseline check is `nvim --headless -c 'qall'` after changes. When editing Lua files, run both formatting and linting. For LSP or UI changes, also verify behavior interactively inside Neovim.

## Commit & Pull Request Guidelines

Local Git history is not available in this workspace, so follow a simple convention: short imperative commit subjects such as `Add neo-tree toggle mapping` or `Fix lua_ls workspace settings`. Keep commits focused on one change. Pull requests should explain the user-visible impact, list validation steps run, and include screenshots or short recordings for UI-facing changes.

## Configuration Notes

Always pass `--config-path .stylelua.toml` to StyLua; it will not auto-detect this filename. This config expects Neovim 0.12+ and uses native `vim.pack`, `blink.cmp`, `gitsigns.nvim`, `neogit`, `neo-tree.nvim`, and several `mini.nvim` modules.
