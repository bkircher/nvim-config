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
    pcall(vim.highlight.on_yank, { higroup = "IncSearch", timeout = 150 })
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

-- Enable Treesitter features for selected languages when they are available.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  desc = "Enable Tree-sitter features when available",
  pattern = {
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
  },
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if not lang or not pcall(vim.treesitter.start, args.buf, lang) then
      return
    end

    -- Preserve the filetype's indentation when no Treesitter query exists.
    if has_treesitter_query(lang, "indents") then
      vim.bo[args.buf].indentexpr =
        "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    if has_treesitter_query(lang, "folds") then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo.foldlevel = 99
    end
  end,
})
