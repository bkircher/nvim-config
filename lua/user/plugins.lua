-- nvim-treesitter: modern setup
-- Highlighting is provided by core via vim.treesitter.start() (see autocmds.lua).
-- Keep the plugin for parser install/update and indentexpr support.
pcall(require, "nvim-treesitter")

-- Builtin opt plugins (Neovim 0.12+)
vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")
