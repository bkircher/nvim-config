local options = {
  backup = false, -- No backup file
  number = true, -- Show line numbers
  termguicolors = true, -- True color
  list = true, -- Show whitespace using listchars
  listchars = "tab:▸ ,eol:¬,trail:·", -- Symbols for tabstops, EOLs, trailing white space
  wrap = true, -- Wrap long lines
  linebreak = true, -- Break lines at word boundaries
  cursorline = true, -- Highlight the current line
  scrolloff = 4, -- Keep some screen lines below/above/left/right of the cursor
  sidescrolloff = 8,
  mouse = "a", -- Enable mouse support
  clipboard = "unnamedplus", -- Use system clipboard
  ignorecase = true, -- Case-insensitive searching…
  smartcase = true, -- …unless uppercase is used
  signcolumn = "yes", -- Always show signcolumn to avoid layout shift
  splitbelow = true, -- Horizontal splits open below
  splitright = true, -- Vertical splits open to the right
  undofile = true, -- Persistent undo
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Don't auto-continue comments on new lines
vim.opt.formatoptions:remove({ 'c', 'r', 'o' })
