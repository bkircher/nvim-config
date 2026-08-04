Nvim-config
===========

This is a minimal Neovim configuration I use for work. It uses Neovim's
built-in `vim.pack` and pins plugin revisions in `nvim-pack-lock.json`.

If you want to learn more about this approach, there are plenty of videos and
channels on YouTube.

Clone this repository:

~~~~
git clone git@github.com:bkircher/nvim-config.git ~/.config/nvim
~~~~


Plugins
-------

This config uses the built-in `vim.pack` plugin manager; see `:help vim.pack`.
Neovim still marks it as experimental, but it is stable enough for daily use.
Plugin sources are declared in `lua/user/plugins.lua`. Exact revisions are
stored in the tracked `nvim-pack-lock.json` file.

`vim.pack` installs plugins under:

~~~~
~/.local/share/nvim/site/pack/core/opt/
~~~~

On the first start after cloning this config, confirm the installation when
Neovim asks. The lockfile makes `vim.pack` install the recorded revisions.

### Installing new plugins

Add the reviewed plugin source to the `vim.pack.add()` call in
`lua/user/plugins.lua`, then restart Neovim. Review and track the resulting
change to `nvim-pack-lock.json`.

### Updating plugins

Start an interactive update from Neovim:

~~~~
:lua vim.pack.update()
~~~~

Review the changes in the confirmation buffer. Use `:write` to apply them or
`:quit` to discard them. Track the resulting lockfile change, then restart
Neovim. After an nvim-treesitter update, run `:TSUpdate` to update parsers if
needed.

### Removing plugins

Remove the plugin source from `lua/user/plugins.lua`, restart Neovim, and then
remove the inactive plugin and its lockfile entry:

~~~~
:lua vim.pack.del({ "plugin-name" })
~~~~

### Tree-sitter parsers

Cloning this configuration does not install its language parsers. The
`nvim-treesitter` installer requires `tar`, `curl`, Tree-sitter CLI 0.26.1 or
later, and a C compiler. Open Neovim and install all parsers configured in
`lua/user/autocmds.lua` with:

~~~~
:TSInstall c lua vimdoc python javascript markdown scheme elixir heex eex
~~~~

The `eex` parser is also used for the `eelixir` file type. The command installs
the pinned parsers and their matching queries; it is a no-op for parsers that
are already installed. Tree-sitter indentation and folding are enabled only when
the parser starts and the relevant query is available, so file type indentation
remains in use otherwise.


Defaults and keymaps
--------------------

 -  The leader key is `\`; the local leader is `,`.
 -  The color scheme is Everforest (dark/hard) with a transparent background.
 -  Tree-sitter is used for highlighting, indentation, and folding in selected
    file types.
 -  Quality-of-life keymaps:
     -  `<C-h/j/k/l>` to move between splits
     -  `Option-Left` and `Option-Right` to move by word in normal and insert
        modes
     -  `<leader>h` to clear search highlighting
     -  `<leader>s` to save the buffer if it has changed
     -  `<leader>l` to toggle whitespace indicators
     -  `<leader>d` to open the current word in macOS Dictionary
 -  Neo-tree: `<leader>b` toggles the file tree.
 -  Telescope fuzzy finder:
     -  `<leader>fb` to list buffers
     -  `<leader>ff` to find files
     -  `<leader>fg` to live grep (requires `ripgrep`)
     -  `<leader>fh` to search help tags
 -  Formatting: `<leader>f` formats Markdown and MDX with `hongdown`, and other
    supported file types with `deno fmt`. Formatting uses the current buffer, so
    unsaved changes are included.
 -  Journal helper: `<leader>j` and `:JournalEntry` open today's journal file
    under `~/journal/YYYY/MM/DD.md` and append a time heading.
 -  Commit messages: `:CommitMsg` generates a commit message from staged changes
    with `pi` (requires `pi` and `seatbelt`).
 -  Neovim 0.12's optional commands are enabled:
     -  `:Undotree` toggles a view of the current buffer's undo history.
     -  `:DiffTool {left} {right}` compares two files or directories side by
        side.
 -  Lua formatting: run `stylua init.lua lua/` from the repo root to
    automatically format Lua code.


Spelling
--------

This config uses a personal word list located at:

~~~~
~/.config/spelling/en.utf-8.add
~~~~

 -  Neovim options set `spellfile` to that path and `spelllang` to `en_us` and
    `de_de`.
 -  Spell checking is enabled automatically for `markdown`, `gitcommit`, and
    `text`. Toggle it with `<leader>ss` in any buffer.
 -  Add words from inside Neovim with `zg` (appends to `en.utf-8.add`).

### Recompile after dictionary changes

Recompilation is optional but recommended after large edits to the dictionary
file.

From inside Neovim:

~~~~
:mkspell! ~/.config/spelling/en.utf-8.add
~~~~

From the shell:

~~~~
$ nvim -n -u NONE -c "silent mkspell! ~/.config/spelling/en.utf-8.add" -c 'qa'
~~~~

Note: adding words with `zg` writes directly to `en.utf-8.add`, and Neovim uses
them immediately.


TODO
----

 -  [ ] Add minimal built-in LSP startup that only activates when servers are
    present (no plugins, no downloads).


Links
-----

 -  Neovim home: <https://neovim.io/>
 -  Neovim docs: <https://neovim.io/doc/>
 -  Neovimcraft: <https://neovimcraft.com/>
 -  `nvim-treesitter` plugin docs:
    <https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#nvim-treesitter>
 -  A `vim.pack` guide:
    <https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack.html>
