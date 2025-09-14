-- Enable faster Lua module loading (Neovim 0.9+)
if vim.loader and vim.loader.enable then
  pcall(vim.loader.enable)
end

-- Set leaders early so mappings use the right leader
vim.g.mapleader = "\\"
vim.g.maplocalleader = ","

-- Disable providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

require "user.options"
require "user.colorscheme"
require "user.rpmspec"
require "user.plugins"
require "user.keymaps"
require "user.autocmds"
require "user.deno"
