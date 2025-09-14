# nvim-config

A very minimal Neovim configuration I use for work. It does not rely on any
plugin managers and does not randomly execute untrusted code from the internet.

Anyway, if you're wondering where you can learn about all this, there are plenty
of videos and channels on YouTube.

Clone this repository:

    git clone git@github.com:bkircher/nvim-config.git ~/.config/nvim

## Plugins

You can easily manage plugins manually in Neovim, see `:help packages`. Here I
use git submodules to install, update, and track plugins inside the Neovim
config directory (`~/.config/nvim`) and use a symlink to the runtime path:

    ~/.local/share/nvim/site/pack/plugins → ~/.config/nvim/plugins

### Installing new plugins

Create the necessary directories and symlinks first. Create the plugin
directory:

    $ mkdir -p ~/.local/share/nvim/site/pack/
    $ cd ~/.local/share/nvim/site/pack

Create a symlink into your Neovim config directory:

    $ ln -s ~/.config/nvim/plugins plugins

Then clone the plugin of your choice into your `~/.config/nvim/plugins/start`
directory. For example, you would install nvim-treesitter as follows

    $ cd ~/.config/nvim
    $ git submodule add git@github.com:nvim-treesitter/nvim-treesitter.git \
        plugins/start/nvim-treesitter

This adds a git submodule to your source tree which you can introspect and
manage with git. For example, with `git submodule` you can list all installed
plugins and the referenced versions:

    $ git submodule
     71a8e8b4b6ebab39765615334d4241a18090a651 plugins/start/nvim-treesitter (v0.9.2-561-g71a8e8b4)

### Updating plugins

To update a plugin, say nvim-treesitter, you would navigate to the plugin
directory and pull the latest changes

    $ cd ~/.config/nvim/plugins/start/nvim-treesitter
    $ git pull

Then, reopen Neovim and run `TSUpdate` again to update parsers if needed.

## Defaults and Keymaps

- Leader key is set to space (`<Space>`). Local leader is `,`.
- Treesitter is configured with highlighting, indentation, and incremental
  selection (`gnn` to init, `grn`/`grm` to inc/dec).
- Quality-of-life keymaps:
  - `<C-h/j/k/l>` to move between splits
  - `<leader>h` to clear search highlight
  - `<leader>w` to save the buffer (if modified)
- Deno formatting: `<leader>f` formats the current buffer via `deno fmt -` if
  `deno` is installed and the filetype/extension is supported.

## TODO

- [ ] Make spelling work with my dictionary
- [ ] Add minimal built-in LSP startup that only activates when servers are
      present (no plugins, no downloads)
- [ ] Enable Treesitter folding
      (`foldmethod=expr, foldexpr=nvim_treesitter#foldexpr()`) with a high
      default foldlevel so nothing collapses unexpectedly
- [ ] Add a tiny statusline using the built-in statusline (no plugins)

## Links

- https://neovim.io/doc/
- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#nvim-treesitter

