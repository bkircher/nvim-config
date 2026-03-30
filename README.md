# nvim-config

A very minimal Neovim configuration I use for work. It does not rely on plugin
managers and does not execute untrusted code from the internet.

If you're wondering where to learn more about this, there are plenty of videos
and channels on YouTube.

Clone this repository:

    git clone git@github.com:bkircher/nvim-config.git ~/.config/nvim

## Plugins

You can easily manage plugins manually in Neovim; see `:help packages`. Here I
use git submodules to install, update, and track plugins inside the Neovim
config directory (`~/.config/nvim`) and use a symlink to the runtime path:

    ~/.local/share/nvim/site/pack/plugins → ~/.config/nvim/plugins

### Installing new plugins

Create the necessary directories and symlink first. Create the plugin directory:

    $ mkdir -p ~/.local/share/nvim/site/pack/
    $ cd ~/.local/share/nvim/site/pack

Create a symlink into your Neovim config directory:

    $ ln -s ~/.config/nvim/plugins plugins

Then clone the plugin of your choice into your `~/.config/nvim/plugins/start`
directory. For example, you would install nvim-treesitter as follows:

    $ cd ~/.config/nvim
    $ git submodule add git@github.com:nvim-treesitter/nvim-treesitter.git \
        plugins/start/nvim-treesitter

This adds a git submodule to your source tree which you can introspect and
manage with git. For example, with `git submodule` you can list all installed
plugins and the referenced versions:

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

- Leader key is `\`. Local leader is `,`.
- Colorscheme is Everforest (dark/hard) with transparent background.
- Treesitter is configured with highlighting, indentation, and incremental
  selection (`gnn` to init, `grn`/`grm` to inc/dec).
- Quality-of-life keymaps:
  - `<C-h/j/k/l>` to move between splits
  - `<leader>h` to clear search highlight
  - `<leader>w` to save the buffer (if modified)
- Deno formatting: `<leader>f` formats the current buffer via `deno fmt -` if
  `deno` is installed and the filetype/extension is supported.
- Lua formatting: run `stylua init.lua lua/` from the repo root to automatically
  format Lua code.

## Spelling

This config uses a personal word list located at:

    ~/.config/spelling/en.utf-8.add

- Neovim options set `spellfile` to that path and set `spelllang` to `en_us` and
  `de_de`.
- Spell is auto-enabled for `markdown`, `gitcommit`, and `text`. Toggle with
  `<leader>ss` in any buffer.
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

## TODO

- [ ] Add minimal built-in LSP startup that only activates when servers are
      present (no plugins, no downloads)

## Links

- <https://neovim.io/doc/>
- <https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#nvim-treesitter>
