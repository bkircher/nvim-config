-- Initialize nvim-treesitter
require('nvim-treesitter').setup {
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

