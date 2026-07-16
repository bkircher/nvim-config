# nvim-config

This is a minimal Neovim configuration I use for work. It does not rely on
plugin managers and does not execute untrusted code from the internet.

If you want to learn more about this approach, there are plenty of videos and
channels on YouTube.

Clone this repository:

    git clone --recurse-submodules git@github.com:bkircher/nvim-config.git \
        ~/.config/nvim

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
with Git. For example, `git submodule` lists installed plugins and their pinned
revisions. Example output:

    $ git submodule
     b03a03148c8b34c24c96960b93da9c8883d11f54 plugins/start/everforest (v0.3.0-116-gb03a031)
     4916d6592ede8c07973490d9322f187e07dfefac plugins/start/nvim-treesitter (v0.9.3-804-g4916d659)
     b9fd5226c2f76c951fc8ed5923d85e4de065e509 plugins/start/plenary.nvim (v0.1.4-38-gb9fd522)
     cfb85dcf7f822b79224e9e6aef9e8c794211b20b plugins/start/telescope.nvim (nvim-0.5.1-665-gcfb85dc)

### Updating plugins

To update a plugin, such as nvim-treesitter, navigate to the plugin directory
and pull the latest changes:

    $ cd ~/.config/nvim/plugins/start/nvim-treesitter
    $ git pull

Then reopen Neovim and run `:TSUpdate` to update parsers if needed.

### Tree-sitter parsers

Cloning this configuration does not install its language parsers. The
`nvim-treesitter` installer requires `tar`, `curl`, Tree-sitter CLI 0.26.1 or
later, and a C compiler. Open Neovim and install all parsers configured in
`lua/user/autocmds.lua` with:

    :TSInstall c lua vimdoc python javascript markdown scheme elixir heex eex

The `eex` parser is also used for the `eelixir` file type. The command installs
the pinned parsers and their matching queries; it is a no-op for parsers that
are already installed. Tree-sitter indentation and folding are enabled only when
the parser starts and the relevant query is available, so file type indentation
remains in use otherwise.

## Defaults and keymaps

- The leader key is `\`; the local leader is `,`.
- The color scheme is Everforest (dark/hard) with a transparent background.
- Tree-sitter is used for highlighting, indentation, and folding in selected
  file types.
- Quality-of-life keymaps:
  - `<C-h/j/k/l>` to move between splits
  - `Option-Left` and `Option-Right` to move by word in normal and insert modes
  - `<leader>h` to clear search highlighting
  - `<leader>s` to save the buffer if it has changed
  - `<leader>l` to toggle whitespace indicators
  - `<leader>d` to open the current word in macOS Dictionary
- Telescope fuzzy finder:
  - `<leader>fb` to list buffers
  - `<leader>ff` to find files
  - `<leader>fg` to live grep (requires `ripgrep`)
  - `<leader>fh` to search help tags
- Deno formatting: `<leader>f` formats the current buffer with `deno fmt` if
  `deno` is installed and the file type or extension is supported.
- Journal helper: `<leader>j` and `:JournalEntry` open today's journal file
  under `~/journal/YYYY/MM/DD.md` and append a time heading.
- Commit messages: `:CommitMsg` generates a commit message from staged changes
  with `pi` (requires `pi` and `seatbelt`).
- Neovim 0.12's optional commands are enabled:
  - `:Undotree` toggles a view of the current buffer's undo history.
  - `:DiffTool {left} {right}` compares two files or directories side by side.
- Lua formatting: run `stylua init.lua lua/` from the repo root to automatically
  format Lua code.

## Spelling

This config uses a personal word list located at:

    ~/.config/spelling/en.utf-8.add

- Neovim options set `spellfile` to that path and `spelllang` to `en_us` and
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
loaded through Neovim's native package system (`pack/*/start/*`) via a symlink.

### What `vim.pack` is

`vim.pack` is a built-in plugin manager added in Neovim 0.12 (`:help vim.pack`):

- It is still marked experimental.
- It uses Git under the hood. It clones repositories into `site/pack/core/opt/`
  (the standard data path, not the config directory).
- It provides `vim.pack.add()`, `.update()`, `.del()`, and `.get()`.
- It generates a lockfile (`nvim-pack-lock.json`) in the config directory to pin
  revisions.
- `vim.pack.add()` auto-installs missing plugins on first run, then calls
  `:packadd` to load them.
- Updates happen interactively through `vim.pack.update()` with a confirmation
  buffer.

### Should I switch?

Not yet:

1. `vim.pack` is experimental. The help explicitly warns that it may change,
   while the submodule approach is stable and well understood.
2. `vim.pack` manages plugins in the data directory
   (`~/.local/share/nvim/site/pack/core/opt/`), not in the config directory
   under `~/.config/nvim/plugins/start/`. With `vim.pack`, plugin sources live
   outside the config and are tracked through a lockfile.
3. Submodules already provide pinned revisions, reproducible clones
   (`--recurse-submodules`), and no dependency on a Neovim API that may still
   change.
4. Manual submodule management is not a problem in this setup, so automating it
   is not a reason to migrate.

If I were starting from scratch with Neovim 0.12+, I would consider `vim.pack`
because it removes the need for the symlink and manual submodule commands. For
the existing setup, avoiding those steps does not justify depending on an
experimental API for now. Let's see what the future brings.

## TODO

- [ ] Add minimal built-in LSP startup that only activates when servers are
      present (no plugins, no downloads).
- [ ] Switch from manual submodules to built-in `vim.pack` when it becomes
      stable.

## Links

- Neovim home: <https://neovim.io/>
- Neovim docs: <https://neovim.io/doc/>
- Neovimcraft: <https://neovimcraft.com/>
- `nvim-treesitter` plugin docs:
  <https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#nvim-treesitter>
- A `vim.pack` guide:
  <https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack.html>
