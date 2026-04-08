# nvim-config

This is a minimal Neovim configuration I use for work. It does not rely on
plugin managers and does not execute untrusted code from the internet.

If you want to learn more about this approach, there are plenty of videos and
channels on YouTube.

Clone this repository:

    git clone git@github.com:bkircher/nvim-config.git ~/.config/nvim

## Plugins

You can manage plugins manually in Neovim; see `:help packages`. In this setup,
I use Git submodules to install, update, and track plugins inside the Neovim
config directory (`~/.config/nvim`), and a symlink exposes them on the runtime
path:

    ~/.local/share/nvim/site/pack/plugins → ~/.config/nvim/plugins

### Installing new plugins

Create the necessary directories and symlink first:

    $ mkdir -p ~/.local/share/nvim/site/pack/
    $ cd ~/.local/share/nvim/site/pack

Create a symlink into your Neovim config directory:

    $ ln -s ~/.config/nvim/plugins plugins

Then clone the plugin of your choice into your `~/.config/nvim/plugins/start`
directory. For example, you would install nvim-treesitter as follows:

    $ cd ~/.config/nvim
    $ git submodule add git@github.com:nvim-treesitter/nvim-treesitter.git \
        plugins/start/nvim-treesitter

This adds a Git submodule to your source tree, which you can inspect and manage
with Git. For example, `git submodule` lists all installed plugins and their
pinned revisions:

    $ git submodule
     b10ed9a8b37d6b7448908be98ff8f58f550adc48 plugins/start/everforest (v0.3.0-114-gb10ed9a)
     7f8dd2e48bc47227d8138a5b5b1fb5a6d6e42237 plugins/start/nvim-treesitter (v0.9.3-576-g7f8dd2e4)

### Updating plugins

To update a plugin, such as nvim-treesitter, navigate to the plugin directory
and pull the latest changes:

    $ cd ~/.config/nvim/plugins/start/nvim-treesitter
    $ git pull

Then reopen Neovim and run `:TSUpdate` again to update parsers if needed.

## Defaults and Keymaps

- The leader key is `\`; the local leader is `,`.
- Colorscheme is Everforest (dark/hard) with transparent background.
- Treesitter is used for highlighting, indentation, and folding in selected
  filetypes.
- Quality-of-life keymaps:
  - `<C-h/j/k/l>` to move between splits
  - `<leader>h` to clear search highlight
  - `<leader>s` to save the buffer if it has changed
- Telescope fuzzy finder:
  - `<leader>fb` to list buffers
  - `<leader>ff` to find files
  - `<leader>fg` to live grep (requires `ripgrep`)
  - `<leader>fh` to search help tags
- Deno formatting: `<leader>f` formats the current buffer via `deno fmt -` if
  `deno` is installed and the filetype/extension is supported.
- Lua formatting: run `stylua init.lua lua/` from the repo root to automatically
  format Lua code.

## Spelling

This config uses a personal word list located at:

    ~/.config/spelling/en.utf-8.add

- Neovim options set `spellfile` to that path and set `spelllang` to `en_us` and
  `de_de`.
- Spell checking is enabled automatically for `markdown`, `gitcommit`, and
  `text`. Toggle it with `<leader>ss` in any buffer.
- Add words from inside Neovim with `zg` (appends to `en.utf-8.add`).

### Recompile after dictionary changes

Recompilation is optional but recommended after large edits to the dictionary
file.

From inside Neovim:

    :mkspell! ~/.config/spelling/en.utf-8.add

From the shell:

    $ nvim -n -u NONE -c "silent mkspell! ~/.config/spelling/en.utf-8.add" -c 'qa'

Note: adding words with `zg` writes directly to `en.utf-8.add`, and Neovim uses
them immediately.

## About `vim.pack`

Neovim 0.12.0 adds a built-in plugin manager. This config currently uses Git
submodules under `plugins/start/`: four plugins are managed as submodules and
loaded through Neovim's native package system (`pack/*/start/*`) via a symlink
[^1].

### What `vim.pack` is

`vim.pack` is a built-in plugin manager added in Neovim 0.12 (`:help vim.pack`):

- It is still marked experimental.
- It uses Git under the hood. It clones repositories into
  `site/pack/core/opt/` (the data standard path, not the config directory).
- It provides `vim.pack.add()`, `.update()`, `.del()`, and `.get()`.
- It generates a lockfile (`nvim-pack-lock.json`) in the config directory to
  pin revisions.
- `vim.pack.add()` auto-installs missing plugins on first run, then calls
  `:packadd` to load them.
- Updates happen interactively through `vim.pack.update()` with a confirmation
  buffer.

### Should we switch?

I would not switch yet. Here's why:

1. `vim.pack` is experimental. The help explicitly warns that it may change,
   while the submodule approach is stable and well understood.
2. It follows a different philosophy. `vim.pack` manages plugins in the data
   directory (`~/.local/share/nvim/site/pack/core/opt/`), not in the config
   directory under `~/.config/nvim/plugins/start/`. With `vim.pack`, plugin
   sources live outside the config and are tracked through a lockfile.
3. The current approach already works well. Submodules give us pinned
   revisions, reproducible clones (`--recurse-submodules`), and no dependency
   on a Neovim API that may still change.
4. There is no major upside for this use case. `vim.pack` mainly helps people
   who do not want to manage submodules manually, and that workflow is already
   in place here.

If we were starting from scratch today on 0.12+, `vim.pack` would be a
reasonable choice. It removes the need for the symlink and manual submodule
commands. But migrating a working setup to an experimental API does not buy
much.

[^1]: The `pcall(require, "nvim-treesitter")` in `lua/user/plugins.lua` just
    ensures the module is available. The plugin itself is already on the
    runtime path from the `start/` directory.

## TODO

- [ ] Add minimal built-in LSP startup that only activates when servers are
      present (no plugins, no downloads).
- [ ] Switch from manual submodules to built-in `vim.pack` when it becomes
      stable.

## Links

- Neovim docs: <https://neovim.io/doc/>
- Treesitter plugin docs:
  <https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#nvim-treesitter>
- A vim.pack guide:
  <https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack.html>
