-- Markdown table alignment
-- - Aligns GitHub Flavored Markdown tables in the Hongdown table style, so
--   :Format keeps the result
-- - Finds tables with the Markdown Tree-sitter parser, so tables in code
--   blocks stay unchanged
-- - Adds :TableAlign and <leader>ct to Markdown buffers; with a range or a
--   Visual selection, aligns all tables that the lines touch

local min_width = 3

local function split_cells(text)
  -- Remove the outer pipes. As in GFM, a pipe after a backslash is cell text,
  -- also in code spans.
  text = vim.trim(text):gsub("^|", "")
  if text:sub(-1) == "|" and text:sub(-2, -2) ~= "\\" then
    text = text:sub(1, -2)
  end

  local cells, start = {}, 1
  for i = 1, #text do
    if text:sub(i, i) == "|" and text:sub(i - 1, i - 1) ~= "\\" then
      table.insert(cells, vim.trim(text:sub(start, i - 1)))
      start = i + 1
    end
  end
  table.insert(cells, vim.trim(text:sub(start)))
  return cells
end

local function is_delimiter_row(cells)
  for _, cell in ipairs(cells) do
    if not cell:match("^:?%-+:?$") then
      return false
    end
  end
  return true
end

-- `marker` is the delimiter cell of the column, for example ":---:".
local function render(cell, width, marker, is_delimiter)
  local left = marker:sub(1, 1) == ":"
  local right = marker:sub(-1) == ":"
  if is_delimiter then
    local dashes = width - (left and 1 or 0) - (right and 1 or 0)
    return (left and ":" or "") .. ("-"):rep(dashes) .. (right and ":" or "")
  end

  local gap = width - vim.api.nvim_strwidth(cell)
  local before = 0
  if left and right then
    before = math.floor(gap / 2)
  elseif right then
    before = gap
  end
  return (" "):rep(before) .. cell .. (" "):rep(gap - before)
end

-- Find the tables that touch the 0-based rows `first` to `last`.
local function find_tables(buf, first, last)
  local parser = vim.treesitter.get_parser(buf, "markdown")
  if not parser then
    return nil
  end

  local tables = {}
  local query = vim.treesitter.query.parse("markdown", "(pipe_table) @table")
  local root = parser:parse()[1]:root()
  -- The query range ends at column 0 of its end row, so use the next row.
  for _, node in query:iter_captures(root, buf, first, last + 1) do
    local start_row, start_col, end_row, end_col = node:range()
    -- The table node ends at column 0 of the line below the table.
    if end_col == 0 then
      end_row = end_row - 1
    end

    if start_row <= last and end_row >= first then
      -- Byte length of the container prefix on each line, for example "> ".
      local prefix_len = { [start_row] = start_col }
      for child in node:iter_children() do
        if child:type() == "block_continuation" then
          local row, _, _, col = child:range()
          prefix_len[row] = col
        end
      end
      table.insert(tables, {
        first = start_row,
        last = end_row,
        prefix_len = prefix_len,
      })
    end
  end
  return tables
end

-- Return the aligned lines and a list of warnings for one table.
local function align(tbl, lines)
  local prefixes, rows = {}, {}
  for i, line in ipairs(lines) do
    -- Keep the container prefix and the indentation of each line.
    local len = tbl.prefix_len[tbl.first + i - 1] or 0
    prefixes[i] = line:sub(1, len) .. line:sub(len + 1):match("^%s*")
    rows[i] = split_cells(line:sub(#prefixes[i] + 1))
  end

  local header, markers = rows[1], rows[2]
  if not markers or #header ~= #markers or not is_delimiter_row(markers) then
    local message = "Line %d: header and delimiter row do not match"
    return nil, { message:format(tbl.first + 1) }
  end

  -- Use display cells, so wide characters such as "日本" count as 4.
  local widths = {}
  for i, cells in ipairs(rows) do
    for col, cell in ipairs(cells) do
      local width = i == 2 and min_width or vim.api.nvim_strwidth(cell)
      widths[col] = math.max(widths[col] or min_width, width)
    end
  end

  local result, warnings = {}, {}
  for i, cells in ipairs(rows) do
    -- GFM adds empty cells to short rows and hides extra cells. Keep the
    -- extra cells, but tell the user about them.
    if #cells > #header then
      local message = "Line %d: more cells than the header; GitHub hides them"
      table.insert(warnings, message:format(tbl.first + i))
    end

    local out = {}
    for col = 1, math.max(#header, #cells) do
      local marker = markers[col] or "-"
      out[col] = render(cells[col] or "", widths[col], marker, i == 2)
    end
    result[i] = prefixes[i] .. "| " .. table.concat(out, " | ") .. " |"
  end
  return result, warnings
end

local function align_tables(opts)
  local buf = vim.api.nvim_get_current_buf()
  local tables = find_tables(buf, opts.line1 - 1, opts.line2 - 1)
  if not tables then
    vim.notify("Markdown Tree-sitter parser not found", vim.log.levels.ERROR)
    return
  end
  if #tables == 0 then
    local place = opts.range == 0 and "at cursor" or "in range"
    vim.notify("No Markdown table " .. place, vim.log.levels.WARN)
    return
  end

  -- Each table keeps its line count, so the rows of later tables stay valid.
  -- All changes of one command are one undo step.
  local view = vim.fn.winsaveview()
  local warnings = {}
  for _, tbl in ipairs(tables) do
    local lines =
      vim.api.nvim_buf_get_lines(buf, tbl.first, tbl.last + 1, false)
    local result, messages = align(tbl, lines)
    vim.list_extend(warnings, messages)
    if result and not vim.deep_equal(lines, result) then
      vim.api.nvim_buf_set_lines(buf, tbl.first, tbl.last + 1, false, result)
    end
  end
  vim.fn.winrestview(view)

  if #warnings > 0 then
    vim.notify(table.concat(warnings, "\n"), vim.log.levels.WARN)
  end
end

local group = vim.api.nvim_create_augroup("user_mdtable", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  desc = "Add Markdown table alignment",
  pattern = "markdown",
  callback = function(args)
    vim.api.nvim_buf_create_user_command(args.buf, "TableAlign", align_tables, {
      desc = "Align Markdown tables at the cursor or in the range",
      range = true,
    })
    vim.keymap.set("n", "<leader>ct", "<Cmd>TableAlign<CR>", {
      buffer = args.buf,
      noremap = true,
      silent = true,
      desc = "Align Markdown table",
    })
    vim.keymap.set("x", "<leader>ct", ":TableAlign<CR>", {
      buffer = args.buf,
      noremap = true,
      silent = true,
      desc = "Align Markdown tables in selection",
    })
  end,
})
