local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Navigation: quick window moves
map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-l>', '<C-w>l', opts)

-- Convenience
map('n', '<leader>s', ':update<CR>', { desc = 'Save buffer (if changed)', silent = true })
map('n', '<leader>h', ':nohlsearch<CR>', { desc = 'Clear search highlight', silent = true })
map('n', '<leader>l', ':set nolist<CR>', { desc = 'Hide whitespace indicators', silent = true })

-- Spelling toggle
map('n', '<leader>ss', function()
  vim.wo.spell = not vim.wo.spell
  vim.notify('spell: ' .. (vim.wo.spell and 'on' or 'off'))
end, { desc = 'Toggle spell' })
