-- Buffer formatter integration
-- - Formats Markdown and MDX with Hongdown
-- - Formats TOML with Taplo and Lua with StyLua
-- - Formats all other files with dprint (with project configuration first and
--   global configuration as the fallback)
-- - Uses stdin/stdout so unsaved changes are included

local formatter_timeout_ms = 5000

local filetype_extensions = {
  javascript = "js",
  javascriptreact = "jsx",
  typescript = "ts",
  typescriptreact = "tsx",
}

local function buffer_ext()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return ""
  end

  return vim.fn.fnamemodify(name, ":e"):lower()
end

local function markdown_mode()
  local ext = buffer_ext()
  if
    ext == "mdx"
    or vim.bo.filetype == "mdx"
    or vim.bo.filetype == "markdown.mdx"
  then
    return "mdx"
  end
  if ext == "md" or ext == "markdown" or vim.bo.filetype == "markdown" then
    return "markdown"
  end
end

local function apply_formatter(command, name)
  if vim.fn.executable(command[1]) ~= 1 then
    vim.notify(command[1] .. " not found in PATH", vim.log.levels.WARN)
    return
  end

  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local input = table.concat(lines, "\n")
  local filename = vim.api.nvim_buf_get_name(buf)
  local cwd = filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()
  local res =
    vim.system(command, { stdin = input, cwd = cwd }):wait(formatter_timeout_ms)
  local output = res.stdout or ""
  local code = res.code or 1

  if code ~= 0 then
    local stderr = res.stderr and vim.trim(res.stderr) or ""
    local message = name .. " failed"
    if stderr ~= "" then
      message = message .. ": " .. stderr
    end
    vim.notify(message, vim.log.levels.ERROR)
    return
  end

  if output == "" then
    return
  end

  output = output:gsub("\r?\n$", "")
  local formatted_lines = vim.split(output, "\n", { plain = true })
  if vim.deep_equal(lines, formatted_lines) then
    return
  end

  -- Apply formatted text back to buffer preserving view.
  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted_lines)
  vim.fn.winrestview(view)
end

local function dprint_fmt()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == "" then
    filename = filetype_extensions[vim.bo.filetype] or vim.bo.filetype
  end
  if filename == "" then
    vim.notify(
      "dprint: set a file name or filetype before formatting",
      vim.log.levels.INFO
    )
    return
  end

  -- Let dprint find project configuration before using global configuration.
  apply_formatter({ "dprint", "fmt", "--stdin", filename }, "dprint")
end

local function hongdown_fmt(mode)
  local command = { "hongdown", "-" }
  if mode == "mdx" then
    command = { "hongdown", "--mdx", "-" }
  end
  apply_formatter(command, "Hongdown")
end

local function taplo_fmt()
  local command = { "taplo", "format", "--colors", "never" }
  local filename = vim.api.nvim_buf_get_name(0)

  if filename ~= "" then
    vim.list_extend(command, { "--stdin-filepath", filename })
  end

  table.insert(command, "-")
  apply_formatter(command, "Taplo")
end

local function stylua_fmt()
  local command = { "stylua", "--search-parent-directories" }
  local filename = vim.api.nvim_buf_get_name(0)

  if filename ~= "" then
    vim.list_extend(command, { "--stdin-filepath", filename })
  end

  table.insert(command, "-")
  apply_formatter(command, "StyLua")
end

local function format_buffer()
  local ext = buffer_ext()
  if ext == "toml" or vim.bo.filetype == "toml" then
    taplo_fmt()
    return
  end

  local mode = markdown_mode()
  if mode then
    hongdown_fmt(mode)
    return
  end

  if ext == "lua" or vim.bo.filetype == "lua" then
    stylua_fmt()
    return
  end

  dprint_fmt()
end

vim.api.nvim_create_user_command(
  "Format",
  format_buffer,
  { desc = "Format current buffer" }
)

vim.keymap.set("n", "<leader>cf", format_buffer, {
  noremap = true,
  silent = true,
  desc = "Format current buffer",
})
