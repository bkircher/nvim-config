-- Initialize nvim-treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "c",
    "lua",
    "vimdoc",
    "python",
    "javascript",
    "markdown",
  },
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

