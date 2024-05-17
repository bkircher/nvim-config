-- Since 0.10, Neovim comes with it's own new default color scheme
-- https://gpanders.com/blog/whats-new-in-neovim-0.10/#colorscheme
vim.cmd [[
  try
    colorscheme solarized
    set background=light
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=light
  endtry
]]
