-- Filetype detection
vim.filetype.add({
  extension = {
    sb = "scheme",
  },
})

local group = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight yanked text",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Auto-detect external file changes
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = group,
  desc = "Check for external file changes",
  command = "checktime",
})

-- Don't auto-continue comments on new lines after ftplugins are applied
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  desc = "Disable automatic comment continuation",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Use four-space indentation for shell scripts
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  desc = "Configure shell script indentation",
  pattern = { "bash", "sh", "zsh" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.tabstop = 4
  end,
})

local function configure_indentation(buf)
  local use_tabs = false
  local min_spaces

  -- Inspect a reasonable prefix rather than potentially loading a huge file.
  local last = math.min(vim.api.nvim_buf_line_count(buf), 1000)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, last, false)) do
    local indent = line:match("^([ \t]+)%S")
    if indent then
      if indent:find("\t", 1, true) then
        use_tabs = true
      else
        min_spaces = math.min(min_spaces or #indent, #indent)
      end
    end
  end

  -- Empty, minified, or otherwise ambiguous files default to two spaces.
  local width = not use_tabs and min_spaces == 4 and 4 or 2

  vim.bo[buf].expandtab = not use_tabs
  vim.bo[buf].shiftwidth = width
  vim.bo[buf].softtabstop = width
  vim.bo[buf].tabstop = width
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  desc = "Detect JSON, JavaScript, and TypeScript indentation",
  pattern = {
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "jsonl",
    "typescript",
    "typescriptreact",
  },
  callback = function(args)
    configure_indentation(args.buf)
  end,
})

-- Enable spellchecking for text files
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  desc = "Enable spell checking for text files",
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

local function has_treesitter_query(lang, query)
  local ok, result = pcall(vim.treesitter.query.get, lang, query)
  return ok and result ~= nil
end

local treesitter_filetypes = {
  "c",
  "lua",
  "vimdoc",
  "python",
  "javascript",
  "markdown",
  "scheme",
  "elixir",
  "heex",
  "eex",
  "eelixir",
}

local treesitter_filetype = {}
for _, filetype in ipairs(treesitter_filetypes) do
  treesitter_filetype[filetype] = true
end

local function start_treesitter(buf)
  if not treesitter_filetype[vim.bo[buf].filetype] then
    return
  end

  local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
  if not lang or not pcall(vim.treesitter.start, buf, lang) then
    return
  end

  return lang
end

-- Enable Treesitter features for selected languages when they are available.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  desc = "Enable Tree-sitter features when available",
  pattern = treesitter_filetypes,
  callback = function(args)
    local lang = start_treesitter(args.buf)
    if not lang then
      return
    end

    -- Preserve the filetype's indentation when no Treesitter query exists.
    if has_treesitter_query(lang, "indents") then
      vim.bo[args.buf].indentexpr =
        "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Folding options are window-local, so reset them whenever a buffer enters a window.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  desc = "Configure Tree-sitter folding",
  callback = function(args)
    vim.wo.foldmethod = "manual"
    vim.wo.foldexpr = "0"
    vim.wo.foldlevel = 0

    local lang = start_treesitter(args.buf)
    if not lang or not has_treesitter_query(lang, "folds") then
      return
    end

    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldlevel = 99
  end,
})
