local options = {
  backup = false, -- No backup file
  number = false, -- Make line numbers default (or not)
  termguicolors = true, -- Sane colors
  listchars = "tab:▸ ,eol:¬,trail:·", -- Symbols for tabstops, EOLs, trailing white space
  wrap = true, -- Do not wrap lines in the middle of a word
  linebreak = true,
  cursorline = true, -- Highlight the current line
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
