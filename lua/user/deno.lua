-- Deno formatter integration
-- - Formats current buffer via `deno fmt -` using stdin/stdout
-- - Adds :DenoFmt command and <leader>f mapping for supported filetypes

local function deno_supported()
  return vim.fn.executable("deno") == 1
end

local function detect_ext()
  -- Prefer current file extension when available; fallback to filetype mapping
  local name = vim.api.nvim_buf_get_name(0)
  local ext = name ~= "" and vim.fn.fnamemodify(name, ":e") or ""
  if ext ~= "" then
    return ext
  end
  local ft = vim.bo.filetype
  local map = {
    javascript = "js",
    javascriptreact = "jsx",
    typescript = "ts",
    typescriptreact = "tsx",
    json = "json",
    jsonc = "jsonc",
    markdown = "md",
  }
  return map[ft]
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

  -- Prefer vim.system (Neovim 0.10+), fallback to systemlist
  local output, code
  if vim.system then
    local res = vim
      .system({ "deno", "fmt", ("--ext=%s"):format(ext), "-" }, { stdin = input })
      :wait()
    output = res.stdout and res.stdout or ""
    code = res.code or 1
  else
    output = table.concat(
      vim.fn.systemlist({ "deno", "fmt", ("--ext=" .. ext), "-" }, input),
      "\n"
    )
    code = vim.v.shell_error
  end

  if code ~= 0 or not output or output == "" then
    vim.notify("Deno fmt failed", vim.log.levels.ERROR)
    return
  end

  -- Apply formatted text back to buffer preserving view
  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    false,
    vim.split(output, "\n", { plain = true })
  )
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
