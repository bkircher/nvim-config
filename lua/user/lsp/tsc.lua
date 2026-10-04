local startup_dir = assert(vim.uv.cwd())
local filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
}

-- Cache version results per workspace for this session.
local supported = {}
local pending = {}

local function executable(root)
  return vim.fs.joinpath(root, "node_modules", ".bin", "tsc")
end

local function root_dir(bufnr, on_dir)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" or vim.bo[bufnr].buftype ~= "" then
    return
  end

  local root = vim.fs.root(bufnr, ".git")
  if not root and vim.fs.relpath(startup_dir, filename) then
    root = startup_dir
  end
  if not root then
    return
  end

  local command = executable(root)
  if vim.fn.executable(command) ~= 1 then
    return
  end

  local function attach()
    -- The buffer or enabled servers can change during the version check.
    if
      vim.api.nvim_buf_is_valid(bufnr)
      and vim.api.nvim_buf_get_name(bufnr) == filename
      and vim.bo[bufnr].buftype == ""
      and vim.tbl_contains(filetypes, vim.bo[bufnr].filetype)
      and vim.lsp.is_enabled("tsc")
    then
      on_dir(root)
    end
  end

  if supported[root] ~= nil then
    if supported[root] then
      attach()
    end
    return
  end

  if pending[root] then
    table.insert(pending[root], attach)
    return
  end
  pending[root] = { attach }

  local finish = vim.schedule_wrap(function(result)
    local version = vim.version.parse(result.stdout or "")
    supported[root] = result.code == 0 and version ~= nil and version.major >= 7
    local callbacks = pending[root]
    pending[root] = nil

    if not supported[root] then
      local detail = vim.trim(result.stderr or "")
      if detail == "" then
        detail = vim.trim(result.stdout or "")
      end
      if result.code == 124 then
        detail = "version check timed out"
      end
      vim.notify(
        "tsc: TypeScript 7 or later is required at "
          .. command
          .. (detail ~= "" and ("\n" .. detail) or ""),
        vim.log.levels.WARN
      )
      return
    end

    for _, callback in ipairs(callbacks) do
      callback()
    end
  end)

  local ok, err = pcall(vim.system, { command, "--version" }, {
    cwd = root,
    text = true,
    timeout = 2000,
  }, finish)
  if not ok then
    finish({ code = 1, stderr = tostring(err) })
  end
end

---@type vim.lsp.Config
return {
  filetypes = filetypes,
  workspace_required = true,
  root_dir = root_dir,
  cmd = function(dispatchers, config)
    local root = assert(config.root_dir)
    local ok, rpc = pcall(vim.lsp.rpc.start, {
      executable(root),
      "--lsp",
      "--stdio",
    }, dispatchers, { cwd = root })
    if not ok then
      supported[root] = false
      error(rpc)
    end
    return rpc
  end,
  on_exit = function(code, signal, client_id)
    -- Neovim reports process errors. Do not retry them for each new buffer.
    if code ~= 0 or (signal ~= 0 and signal ~= 15) then
      local client = vim.lsp.get_client_by_id(client_id)
      if client then
        supported[client.config.root_dir] = false
      end
    end
  end,
}
