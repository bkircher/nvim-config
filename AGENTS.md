# AGENTS.md

## Overview

This is a minimal Neovim configuration that avoids plugin managers and doesn't
execute untrusted code from the internet. The configuration uses git submodules
for plugin management and manual package management via Neovim's built-in
`packages` system (see `:help packages`).

Assumes Neovim 0.11.0+.

## Architecture

- `init.lua` - Main entry point that requires all user modules
- `lua/user/` - Contains all configuration modules:
  - `options.lua` - Basic Neovim options and settings
  - `colorscheme.lua` - Color scheme configuration (Everforest Dark Hard with
    fallback to defaults)
  - `plugins.lua` - nvim-treesitter plugin bootstrap (parsers/indent support;
    highlighting configured in `autocmds.lua`)
  - `keymaps.lua` - Core keymaps (leader, window nav, helpers)
  - `autocmds.lua` - Small quality-of-life autocommands (including Treesitter
    highlight/indent/fold)
  - `deno.lua` - Deno formatter integration (`<leader>f` keybinding)
  - `rpmspec.lua` - RPM spec file changelog helper configuration
  - `journal.lua` - Simple daily journal helper (`<leader>j`, `:JournalEntry`)
  - `commitmsg.lua` - Generate commit message generator via gemini (`:CommitMsg`)
  - `editeng.lua` - English text editor via gemini (`:EditEng` on a visual selection)
- `plugins/start/` - Plugin directory managed via git submodules
  - Contains nvim-treesitter for syntax highlighting and everforest for the
    colorscheme

## Plugin Management

### Installing Plugins

```bash
# Add new plugin as git submodule
cd ~/.config/nvim
git submodule add <plugin-git-url> plugins/start/<plugin-name>
```

Fresh clone setup (ensure submodules are fetched):

```bash
git clone --recurse-submodules <repo-url> ~/.config/nvim
# or, if already cloned
git -C ~/.config/nvim submodule update --init --recursive
```

### Updating Plugins

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

### Listing Plugins

```bash
git submodule
```

## Key Features

- **Treesitter Integration**: Configured for C, Lua, Vimdoc, Python, JavaScript,
  Markdown, Elixir, HEEx, EEx, and EElixir
- **Everforest Theme**: Dark/Hard variant with transparent background
- **Deno Formatting**: `<leader>f` formats current file using `deno fmt -`
  (stdin)
- **RPM Spec Support**: Changelog format helper for RPM spec files
- **Minimal Dependencies**: No plugin manager, uses Neovim's native package
  system
- **Journal Helper**: `<leader>j` or `:JournalEntry` opens
  `~/journal/YYYY/MM/DD.md` and appends a timestamp heading at EOF
- **Folding/Indent**: Treesitter-backed folding and indent for selected
  filetypes

## Keymaps & Commands

- Leaders: `\` (global), `,` (local)
- Window move: `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`
- Save-if-changed: `<leader>s`
- Clear search highlight: `<leader>h`
- Toggle whitespace indicators: `<leader>l`
- Toggle spell: `<leader>ss`
- Deno format: `<leader>f` or `:DenoFmt`
- Journal: `<leader>j` or `:JournalEntry`
- Generate commit message: `:CommitMsg`
- Edit English text: `:'<,'>EditEng` (visual selection)

## Development Workflow

1. Plugin modifications should be made in `lua/user/plugins.lua`
2. New keybindings and tools can be added as separate modules in `lua/user/`
3. Always require new modules in `init.lua`
4. Use git submodules for any new plugin installations
5. To enable Treesitter features for more languages, add filetypes to the
   `FileType` autocmd patterns in `lua/user/autocmds.lua`
6. Format Lua code by running `stylua init.lua lua/` from the repo root

### Agent Conventions (please follow)

- Do not introduce plugin managers; use git submodules under `plugins/start/`
- Keep configuration minimal and readable; prefer Neovim built-ins
- Avoid executing remote or unpinned code; keep submodules pinned
- Match coding style in existing files; avoid unnecessary refactors
- When adding modules under `lua/user/`, document them here and require in
  `init.lua`

## Symlink Setup

The configuration expects a symlink:

```bash
~/.local/share/nvim/site/pack/plugins → ~/.config/nvim/plugins
```

This allows Neovim to discover plugins in the `plugins/start/` directory.

Create or fix the symlink explicitly (with user confirmation):

```bash
mkdir -p ~/.local/share/nvim/site/pack
ln -snf ~/.config/nvim/plugins ~/.local/share/nvim/site/pack/plugins
```

Verify inside Neovim:

- `:set packpath?` includes `~/.local/share/nvim/site`
- `:h packages` shows the `pack/*/start` layout

## Troubleshooting

- Deno format does nothing: ensure `deno` is on `PATH` (`deno --version`).
- Treesitter highlight/folding missing:
  - Open Neovim and run `:checkhealth nvim-treesitter`
  - Run `:TSUpdate` after updating the submodule
  - Confirm the filetype is listed in the `FileType` autocmd in `autocmds.lua`
- Plugins not detected: re-create the symlink under Symlink Setup.
- Spellfile warnings: ensure `~/.config/spelling/en.utf-8.add` exists or update
  `spellfile` in `options.lua`.
- Journal path: files are created under `~/journal/YYYY/MM/DD.md` automatically;
  ensure `~/journal` is writable.

## Notes

- Colorscheme uses Everforest (dark/hard) with transparent background
  highlights; falls back to Neovim defaults if unavailable.
- `vim.loader` (0.9+) and `vim.system` (0.10+) are used when available with
  fallbacks for older versions.
