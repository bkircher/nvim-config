-- This will allow you to press `<leader>f` in normal mode to format the
-- current Markdown or JavaScript file.
vim.api.nvim_set_keymap('n', '<leader>f', ':!deno fmt %<CR>', { noremap = true, silent = true })

