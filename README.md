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


Language servers
----------------

LSP setup uses Neovim's built-in client. The enabled server list and shared
completion setup are in `lua/user/lsp.lua`. Each server has a module under
`lua/user/lsp/` that returns a `vim.lsp.Config`.

Servers must use workspace-local executables. Neovim does not install servers,
run package scripts, or fall back to global installations. Different servers
can run in the same workspace and attach to the same buffer. Neovim reuses
clients by server name and workspace.

### TypeScript

The initial server is TypeScript's native `tsc` language server. It supports
JavaScript, JSX, TypeScript, and TSX. Install and pin TypeScript 7 or later in
the project's dependencies and lockfile.

For each file, the workspace is:

1.  The nearest parent with a `.git` file or directory.
2.  Otherwise, Neovim's startup working directory, but only if it contains
    the file.

The server command is:

~~~~
<workspace>/node_modules/.bin/tsc --lsp --stdio
~~~~

The server runs with that workspace as its working directory. A monorepo uses
one installation at its root, not separate installations in each package.
Neither `package.json` nor `tsconfig.json` creates a separate LSP workspace.

Only the root-local `tsc` is considered. There is no `tsgo`, TypeScript 6,
parent-directory, or `$PATH` fallback. Missing executables are skipped without
a warning. The local version check is asynchronous, has a two-second timeout,
and is shared by buffers in the same workspace. Unsupported versions and failed
checks produce one warning per workspace. Neovim reports server process errors.

Version results and server failures are cached for the session. Restart
Neovim after changing or repairing a server installation. Changing Neovim's
working directory does not change the startup-directory fallback.

The pnpm launcher is supported without special configuration. It can use
Node.js from `$PATH`; the language server remains project-local. Project
patches, such as `effect-tsgo patch`, remain the project's responsibility.
Neovim uses the resulting local `tsc` and does not apply patches or configure
Effect itself.

### Built-in controls

| Mode   | Mapping      | Action                 |
| ------ | ------------ | ---------------------- |
| Normal | `K`          | Show hover information |
| Normal | `<C-]>`      | Go to a definition     |
| Normal | `grr`        | Find references        |
| Normal | `grn`        | Rename a symbol        |
| Normal | `gra`        | Select a code action   |
| Normal | `[d` / `]d`  | Go to a diagnostic     |
| Insert | `<C-s>`      | Show signature help    |
| Insert | `<C-x><C-o>` | Request completion     |
| Insert | `<C-y>`      | Accept a completion    |

Completion uses Neovim's built-in support, with no automatic popup. Diagnostics
and navigation use the default behavior. Features depend on server support.
The existing `:Format` and `<leader>cf` commands are unchanged; LSP does not add
format-on-save.

Use `:checkhealth vim.lsp` to inspect the setup and attached clients.

### Adding another server

Add a module such as `lua/user/lsp/example.lua` and add its name to the
`servers` list in `lua/user/lsp.lua`. The module defines file types, a
workspace-local command, root selection, and any server-specific checks.
Use the Git-root/startup-directory policy unless the server needs another
rule. Keep caches inside that module and separate them by workspace.


Defaults and keymaps
--------------------

 -  The leader key is `\`; the local leader is `,`.
 -  The color scheme is Everforest (dark/hard) with a transparent background.
 -  Tree-sitter is used for highlighting, indentation, and folding in selected
    file types.

### Custom key mappings

| Mode         | Mapping                  | Action                                                          |
| ------------ | ------------------------ | --------------------------------------------------------------- |
| Normal       | `<C-h>`                  | Move to the left window                                         |
| Normal       | `<C-j>`                  | Move to the window below                                        |
| Normal       | `<C-k>`                  | Move to the window above                                        |
| Normal       | `<C-l>`                  | Move to the right window                                        |
| Normal       | `Option-Left` (`<M-b>`)  | Move to the previous word                                       |
| Normal       | `Option-Right` (`<M-f>`) | Move to the next word                                           |
| Normal       | `<leader>b`              | Toggle the file tree                                            |
| Normal       | `<leader>cf`             | Format the current buffer                                       |
| Normal       | `<leader>ct`             | Align the Markdown table at the cursor                          |
| Normal       | `<leader>d`              | Open the current word in macOS Dictionary                       |
| Normal       | `<leader>fb`             | List buffers                                                    |
| Normal       | `<leader>ff`             | Find files                                                      |
| Normal       | `<leader>fg`             | Search text with live grep (requires `ripgrep`)                 |
| Normal       | `<leader>fh`             | Search help tags                                                |
| Normal       | `<leader>h`              | Clear search highlighting                                       |
| Normal       | `<leader>j`              | Create a journal entry                                          |
| Normal       | `<leader>l`              | Toggle whitespace indicators                                    |
| Normal       | `<leader>ts`             | Toggle spelling                                                 |
| Normal       | `<leader>w`              | Save the buffer if it changed                                   |
| Visual       | `<leader>ct`             | Align the Markdown tables in the selection                      |
| Insert       | `Option-Left` (`<M-b>`)  | Move to the previous word                                       |
| Insert       | `Option-Right` (`<M-f>`) | Move to the next word                                           |
| Command line | `<Up>`                   | Select the previous completion, or move through command history |
| Command line | `<Down>`                 | Select the next completion, or move through command history     |


Spelling
--------

This config uses a personal word list located at:

~~~~
~/.config/spelling/en.utf-8.add
~~~~

 -  Neovim options set `spellfile` to that path and `spelllang` to `en_us` and
    `de_de`.
 -  Spell checking is enabled automatically for `markdown`, `gitcommit`, and
    `text`. Toggle it with `<leader>ts` in any buffer.
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


Links
-----

 -  Neovim home: <https://neovim.io/>
 -  Neovim docs: <https://neovim.io/doc/>
 -  Neovimcraft: <https://neovimcraft.com/>
 -  `nvim-treesitter` plugin docs:
    <https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#nvim-treesitter>
 -  A `vim.pack` guide:
    <https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack.html>
