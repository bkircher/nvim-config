local options = {
  backup = false, -- No backup file
  number = true, -- Make line numbers default
  termguicolors = true, -- Sane colors
  listchars = "tab:▸ ,eol:¬,trail:·", -- Symbols for tabstops, EOLs, trailing white space
  wrap = true, -- Do not wrap lines in the middle of a word
  linebreak = true,
  cursorline = true, -- Highlight the current line
  scrolloff = 4, -- Keep some screen lines below, above, or right to the cursor
  sidescrolloff = 8,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
