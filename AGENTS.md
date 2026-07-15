# AGENTS.md

This configuration requires Neovim 0.12.0+.

## Development guidelines

- Add new configuration modules under `lua/user/` and require them from
  `init.lua`.
- Configure Treesitter filetypes in the `FileType` autocmds in
  `lua/user/autocmds.lua`.
- Do not introduce a plugin manager. Plugins are pinned Git submodules under
  `plugins/start/`.
- Prefer Neovim built-ins and keep the configuration minimal.
- Do not execute remote or unpinned code.
- Match the existing style and avoid unnecessary refactors.
- After changing Lua files, run `stylua init.lua lua/` from the repository root.

See `README.md` for setup, plugin-management commands, features, and keymaps.
