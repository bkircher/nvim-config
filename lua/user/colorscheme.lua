-- Since 0.10, Neovim comes with it's own new default color scheme
-- https://gpanders.com/blog/whats-new-in-neovim-0.10/#colorscheme
vim.cmd [[
  try
    colorscheme default
    set background=dark
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme vim
    set background=light
  endtry
]]

-- Make background transparent to work with any terminal theme
vim.cmd [[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
]]
