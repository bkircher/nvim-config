# AGENTS.md

## Overview

This is a minimal Neovim configuration that avoids plugin managers. The
configuration uses Git submodules for plugin management and manual package
management via Neovim's built-in `packages` system (see `:help packages`).

This configuration assumes Neovim 0.12.0+.

## Architecture

- `init.lua` - Main entry point that requires all user modules
- `lua/user/` - Contains all configuration modules:
  - `options.lua` - Basic Neovim options and settings
  - `colorscheme.lua` - Color scheme configuration (Everforest Dark Hard with
    fallback to defaults)
  - `plugins.lua` - nvim-treesitter plugin bootstrap (parsers/indent support;
    highlighting configured in `autocmds.lua`)
  - `keymaps.lua` - Core keymaps (leader, window navigation, helpers)
  - `autocmds.lua` - Small quality-of-life autocommands (including Treesitter
    highlight/indent/fold)
  - `deno.lua` - Deno formatter integration (`<leader>f` keybinding)
  - `rpmspec.lua` - RPM spec file changelog helper configuration
  - `journal.lua` - Simple daily journal helper (`<leader>j`, `:JournalEntry`)
  - `commitmsg.lua` - Generate git commit messages via pi (`:CommitMsg`)
  - `telescope.lua` - Telescope fuzzy finder keymaps (find files, live grep,
    buffers, help tags)
- `plugins/start/` - Plugin directory managed via Git submodules
  - Contains nvim-treesitter for syntax highlighting, everforest for the
    colorscheme, telescope.nvim for fuzzy finding (with plenary.nvim dependency)

## Plugin management

### Installing plugins

```bash
# Add a new plugin as a Git submodule
cd ~/.config/nvim
git submodule add <plugin-git-url> plugins/start/<plugin-name>
```

Fresh clone setup (ensure submodules are fetched):

```bash
git clone --recurse-submodules <repo-url> ~/.config/nvim
# or, if already cloned
git -C ~/.config/nvim submodule update --init --recursive
```

### Updating plugins

```bash
# Update specific plugin
cd ~/.config/nvim/plugins/start/<plugin-name>
git pull

# For nvim-treesitter, also run :TSUpdate in Neovim
```

Update all plugins (optional):

```bash
cd ~/.config/nvim
git submodule foreach git pull
```

### Listing plugins

```bash
git submodule
```

## Development workflow

1. Plugin modifications should be made in `lua/user/plugins.lua`
2. New keybindings and tools can be added as separate modules in `lua/user/`
3. Always require new modules in `init.lua`
4. Use Git submodules for any new plugin installations
5. To enable Treesitter features for more languages, add filetypes to the
   `FileType` autocmd patterns in `lua/user/autocmds.lua`
6. Ensure Lua code is formatted by running `stylua init.lua lua/` from the repo
   root

## Conventions

- Do not introduce plugin managers; use Git submodules under `plugins/start/`
- Keep configuration minimal and readable; prefer Neovim built-ins
- Avoid executing remote or unpinned code; keep submodules pinned
- Match coding style in existing files; avoid unnecessary refactors
