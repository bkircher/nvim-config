local options = {
  backup = false, -- No backup file
  number = true, -- Make line numbers default
  termguicolors = true, -- Sane colors
  listchars = "tab:▸ ,eol:¬,trail:·" -- Symbols for tabstops, EOLs, trailing white space
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
