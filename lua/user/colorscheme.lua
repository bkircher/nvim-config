vim.g.everforest_background = "hard"
vim.g.everforest_transparent_background = 1
vim.opt.background = "dark"

local ok = pcall(vim.cmd.colorscheme, "everforest")

if not ok then
  -- Since 0.10, Neovim ships a new default colorscheme; keep it as a fallback
  vim.cmd [[
    try
      colorscheme default
      set background=dark
    catch /^Vim\%((\a\+)\)\=:E185/
      colorscheme vim
      set background=light
    endtry
  ]]
end

-- Make background transparent to work with any terminal theme
vim.cmd [[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
]]
