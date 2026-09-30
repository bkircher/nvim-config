vim.g.everforest_background = "hard"
vim.g.everforest_transparent_background = 1
vim.o.background = "light"

local ok = pcall(function()
  local onedark = require("onedark")
  onedark.setup({
    style = "light",
    transparent = true,
  })
  onedark.load()
end)

if not ok and not pcall(vim.cmd.colorscheme, "everforest") then
  -- Use Neovim's default colorscheme if neither plugin is available
  vim.cmd([[
    try
      colorscheme default
      set background=light
    catch /^Vim\%((\a\+)\)\=:E185/
      colorscheme vim
      set background=light
    endtry
  ]])
end

-- Make background transparent to work with any terminal theme
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
]])
