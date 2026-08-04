vim.pack.add({
  "https://github.com/sainnhe/everforest.git",
  "https://github.com/nvim-treesitter/nvim-treesitter.git",
  "https://github.com/nvim-lua/plenary.nvim.git",
  "https://github.com/nvim-telescope/telescope.nvim.git",
})

-- Built-in optional plugins
vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")
