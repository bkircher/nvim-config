-- Buffer formatter integration
-- - Formats Markdown and MDX with Hongdown
-- - Formats Deno-supported filetypes with `deno fmt`
-- - Uses stdin/stdout so unsaved changes are included

local extension_aliases = {
  cjs = "cjs",
  cts = "cts",
  ipynb = "ipynb",
  js = "js",
  jsx = "jsx",
  markdown = "md",
  md = "md",
  mjs = "mjs",
  mts = "mts",
  json = "json",
  jsonc = "jsonc",
  ts = "ts",
  tsx = "tsx",
}

local filetype_extensions = {
  javascript = "js",
  javascriptreact = "jsx",
  typescript = "ts",
  typescriptreact = "tsx",
  json = "json",
  jsonc = "jsonc",
  markdown = "md",
}

local function canonicalize_ext(ext)
  return extension_aliases[ext:lower()]
end

local function buffer_ext()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return ""
  end

  return vim.fn.fnamemodify(name, ":e"):lower()
end

local function detect_deno_ext()
  -- Prefer a supported file extension; fallback to the filetype mapping.
  return canonicalize_ext(buffer_ext()) or filetype_extensions[vim.bo.filetype]
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
  local res = vim.system(command, { stdin = input }):wait()
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

local function deno_fmt()
  local ext = detect_deno_ext()
  if not ext then
    vim.notify("Deno fmt: unsupported filetype", vim.log.levels.INFO)
    return
  end

  apply_formatter({ "deno", "fmt", ("--ext=%s"):format(ext), "-" }, "Deno fmt")
end

local function hongdown_fmt(mode)
  local command = { "hongdown", "-" }
  if mode == "mdx" then
    command = { "hongdown", "--mdx", "-" }
  end
  apply_formatter(command, "Hongdown")
end

local function format_buffer()
  local mode = markdown_mode()
  if mode then
    hongdown_fmt(mode)
    return
  end

  deno_fmt()
end

vim.api.nvim_create_user_command(
  "Format",
  format_buffer,
  { desc = "Format current buffer" }
)
vim.api.nvim_create_user_command(
  "DenoFmt",
  deno_fmt,
  { desc = "Format current buffer with deno fmt" }
)

vim.keymap.set("n", "<leader>f", format_buffer, {
  noremap = true,
  silent = true,
  desc = "Format current buffer",
})
