-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    pcall(vim.highlight.on_yank, { higroup = 'IncSearch', timeout = 150 })
  end,
})

-- Auto-detect external file changes
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  command = 'checktime',
})

