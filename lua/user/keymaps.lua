local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Navigation: quick window moves
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Word navigation with Option+Left/Right; Ghostty sends these as Esc-b/f
map("n", "<M-b>", "b", { desc = "Move to previous word" })
map("n", "<M-f>", "w", { desc = "Move to next word" })
map("i", "<M-b>", "<C-Left>", { desc = "Move to previous word" })
map("i", "<M-f>", "<C-Right>", { desc = "Move to next word" })

-- Convenience
map(
  "n",
  "<leader>s",
  ":update<CR>",
  { desc = "Save buffer (if changed)", silent = true }
)
map(
  "n",
  "<leader>h",
  ":nohlsearch<CR>",
  { desc = "Clear search highlight", silent = true }
)
map("n", "<leader>l", function()
  vim.wo.list = not vim.wo.list
  vim.notify("list: " .. (vim.wo.list and "on" or "off"))
end, { desc = "Toggle whitespace indicators", silent = true })

-- macOS Dictionary lookup
map("n", "<leader>d", function()
  local word = vim.fn.expand("<cword>")
  vim.fn.system({ "open", "dict://" .. word })
end, { desc = "Open word in macOS Dictionary" })

-- Spelling toggle
map("n", "<leader>ss", function()
  vim.wo.spell = not vim.wo.spell
  vim.notify("spell: " .. (vim.wo.spell and "on" or "off"))
end, { desc = "Toggle spell" })
