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

-- Enable spellchecking for text files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'gitcommit', 'text' },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Enable Treesitter highlighting and indent for selected languages
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'c', 'lua', 'vimdoc', 'python', 'javascript', 'markdown',
    'elixir', 'heex', 'eex', 'eelixir',
  },
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
