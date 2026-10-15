vim.g.everforest_background = "soft"
vim.g.everforest_transparent_background = 0
vim.o.background = "dark"

if not pcall(vim.cmd.colorscheme, "everforest") then
  -- Use Neovim's default colorscheme if the plugin is unavailable
  vim.cmd([[
    try
      colorscheme default
      set background=dark
    catch /^Vim\%((\a\+)\)\=:E185/
      colorscheme vim
      set background=dark
    endtry
  ]])
end
