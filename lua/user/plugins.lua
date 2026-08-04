vim.pack.add({
  "https://github.com/sainnhe/everforest.git",
  "https://github.com/nvim-treesitter/nvim-treesitter.git",
  "https://github.com/nvim-lua/plenary.nvim.git",
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    version = vim.version.range("3"),
  },
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-telescope/telescope.nvim.git",
})

-- Built-in optional plugins
vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")
