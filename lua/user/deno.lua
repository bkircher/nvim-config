-- Deno formatter integration
-- - Formats current buffer via `deno fmt -` using stdin/stdout
-- - Adds :DenoFmt command and <leader>f mapping for supported filetypes

local function deno_supported()
  return vim.fn.executable("deno") == 1
end

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

local function detect_ext()
  -- Prefer a supported file extension; fallback to the filetype mapping.
  local name = vim.api.nvim_buf_get_name(0)
  local ext = name ~= "" and vim.fn.fnamemodify(name, ":e") or ""
  return canonicalize_ext(ext) or filetype_extensions[vim.bo.filetype]
end

local function deno_fmt()
  if not deno_supported() then
    vim.notify("deno not found in PATH", vim.log.levels.WARN)
    return
  end

  local ext = detect_ext()
  if not ext then
    vim.notify("Deno fmt: unsupported filetype", vim.log.levels.INFO)
    return
  end

  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local input = table.concat(lines, "\n")

  local res = vim
    .system({ "deno", "fmt", ("--ext=%s"):format(ext), "-" }, { stdin = input })
    :wait()
  local output = res.stdout or ""
  local code = res.code or 1

  if code ~= 0 then
    local stderr = res.stderr and vim.trim(res.stderr) or ""
    local message = "Deno fmt failed"
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

  -- Apply formatted text back to buffer preserving view
  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted_lines)
  vim.fn.winrestview(view)
end

vim.api.nvim_create_user_command(
  "DenoFmt",
  deno_fmt,
  { desc = "Format current buffer with deno fmt" }
)

-- Map <leader>f to deno fmt for supported filetypes
vim.keymap.set("n", "<leader>f", function()
  deno_fmt()
end, { noremap = true, silent = true, desc = "Format with deno fmt" })
