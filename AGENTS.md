AGENTS.md
=========

This configuration requires Neovim 0.12.0+.

 -  Neovim sources are available under `~/src/neovim` and may be consulted for
    implementation details.
 -  Add new configuration modules under `lua/user/` and require them from
    `init.lua`.
 -  Configure Treesitter filetypes in the `FileType` autocmds in
    `lua/user/autocmds.lua`.
 -  Use Neovim's built-in `vim.pack` for plugins. Do not introduce a third-party
    plugin manager. Declare plugins in `lua/user/plugins.lua` and track
    `nvim-pack-lock.json`.
 -  Prefer Neovim built-ins and keep the configuration minimal.
 -  Prefer `vim.o`, `vim.bo`, and `vim.wo` over `vim.opt`, `vim.opt_local`, and
    `vim.opt_global`; use `vim.bo` for buffer-local options and `vim.wo` for
    window-local options such as `spell`.
 -  Do not execute remote or unpinned code.
 -  Match the existing style and avoid unnecessary refactors.
 -  After changing Lua files, run `stylua init.lua lua/` from the repository
    root.
