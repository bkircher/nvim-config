# AGENTS.md

## Overview

This is a minimal Neovim configuration that avoids plugin managers and doesn't
execute untrusted code from the internet. The configuration uses git submodules
for plugin management and manual package management via Neovim's built-in
`:help packages` system.

Code assumes Neovim 11.0 and later is used.

## Architecture

- `init.lua` - Main entry point that requires all user modules
- `lua/user/` - Contains all configuration modules:
  - `options.lua` - Basic Neovim options and settings
  - `colorscheme.lua` - Color scheme configuration (uses new default dark theme)
  - `plugins.lua` - nvim-treesitter configuration with syntax highlighting
  - `keymaps.lua` - Core keymaps (leader, window nav, helpers)
  - `autocmds.lua` - Small quality-of-life autocommands
  - `deno.lua` - Deno formatter integration (`<leader>f` keybinding)
  - `rpmspec.lua` - RPM spec file changelog helper configuration
- `plugins/start/` - Plugin directory managed via git submodules
  - Contains nvim-treesitter as the primary plugin for syntax highlighting

## Plugin Management

### Installing Plugins

```bash
# Add new plugin as git submodule
cd ~/.config/nvim
git submodule add <plugin-git-url> plugins/start/<plugin-name>
```

### Updating Plugins

```bash
# Update specific plugin
cd ~/.config/nvim/plugins/start/<plugin-name>
git pull

# For nvim-treesitter, also run :TSUpdate in Neovim
```

### Listing Plugins

```bash
git submodule
```

## Key Features

- **Treesitter Integration**: Configured for C, Lua, Vimdoc, Python, JavaScript,
  Markdown, and Elixir
- **Deno Formatting**: `<leader>f` formats current file using `deno fmt -`
  (stdin)
- **RPM Spec Support**: Changelog format helper for RPM spec files
- **Minimal Dependencies**: No plugin manager, uses Neovim's native package
  system

## Development Workflow

1. Plugin modifications should be made in `lua/user/plugins.lua`
2. New keybindings and tools can be added as separate modules in `lua/user/`
3. Always require new modules in `init.lua`
4. Use git submodules for any new plugin installations

## Symlink Setup

The configuration expects a symlink:

```bash
~/.local/share/nvim/site/pack/plugins → ~/.config/nvim/plugins
```

This allows Neovim to discover plugins in the `plugins/start/` directory.

