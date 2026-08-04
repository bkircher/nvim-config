require("neo-tree").setup({
  default_component_configs = {
    icon = {
      enabled = false,
    },
  },
})

vim.keymap.set("n", "<leader>b", "<Cmd>Neotree toggle<CR>", {
  desc = "Toggle file tree",
  silent = true,
})
