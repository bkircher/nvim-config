-- Journal entry helper
--
-- - Opens ~/journal/YYYY/MM/DD.md
-- - Appends "# h:mm AM/PM" and a blank line at EOF

local function today_path()
  local root = vim.fn.expand('~/journal')
  local y = os.date('%Y')
  local m = os.date('%m')
  local d = os.date('%d')
  return string.format('%s/%s/%s/%s.md', root, y, m, d)
end

local function time_heading()
  local hour = tonumber(os.date('%I'))  -- 1..12 without leading zero
  local min = os.date('%M')
  local ampm = string.upper(os.date('%p'))
  return string.format('# %d:%s %s', hour, min, ampm)
end

local function ensure_parent(path)
  local dir = vim.fn.fnamemodify(path, ':h')
  vim.fn.mkdir(dir, 'p')
end

local function append_heading_at_eof(bufnr)
  bufnr = bufnr or 0
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local last = ''
  if line_count > 0 then
    last = vim.api.nvim_buf_get_lines(bufnr, line_count - 1, line_count, false)[1] or ''
  end

  local to_add = {}
  if last ~= '' then
    table.insert(to_add, '')
  end
  table.insert(to_add, time_heading())
  table.insert(to_add, '')

  -- If the buffer is a brand-new empty file (single empty line),
  -- overwrite that line so there's no leading blank before the first heading.
  -- A bit hacky but it works.
  if line_count == 1 and last == '' then
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, to_add)
  else
    vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, to_add)
  end
  vim.cmd.normal('G')
end

local function journal_entry()
  local path = today_path()
  ensure_parent(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  append_heading_at_eof(0)
end

vim.api.nvim_create_user_command('JournalEntry', journal_entry, { desc = "Create a new journal entry" })
vim.keymap.set('n', '<leader>j', journal_entry, { noremap = true, silent = true, desc = 'Journal: new entry' })
