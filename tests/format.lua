-- Run from the repository root: nvim --clean -i NONE --headless -l tests/format.lua
vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath

local tests = {}

local function test(name, run)
  tests[#tests + 1] = { name = name, run = run }
end

local function cases(name, values, run)
  for _, value in ipairs(values) do
    test(name .. ": " .. value.name, function(env)
      run(env, value)
    end)
  end
end

local function equal(expected, actual)
  assert(
    vim.deep_equal(expected, actual),
    "Expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual)
  )
end

local function setup()
  local env = {
    executables = { hongdown = 1, taplo = 1, stylua = 1, dprint = 1 },
    jobs = {},
    notices = {},
    result = { code = 0, stdout = "formatted\n", stderr = "" },
  }
  local restores = {}

  local function stub(object, key, value)
    local original = object[key]
    restores[#restores + 1] = function()
      object[key] = original
    end
    object[key] = value
  end

  stub(vim.fn, "executable", function(command)
    return env.executables[command] or 0
  end)
  stub(vim.fn, "getcwd", function()
    return "/startup"
  end)
  stub(vim, "notify", function(message, level)
    env.notices[#env.notices + 1] = { message = message, level = level }
  end)
  stub(vim, "system", function(command, options)
    local job = { command = command, options = options }
    env.jobs[#env.jobs + 1] = job
    return {
      wait = function(_, timeout_ms)
        job.timeout_ms = timeout_ms
        return env.result
      end,
    }
  end)

  env.bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_current_buf(env.bufnr)
  vim.api.nvim_buf_set_name(env.bufnr, "/workspace/src/main.ts")
  vim.bo[env.bufnr].filetype = "typescript"
  vim.api.nvim_buf_set_lines(env.bufnr, 0, -1, false, { "const value=1" })

  package.loaded["user.format"] = nil
  require("user.format")

  env.cleanup = function()
    pcall(vim.api.nvim_del_user_command, "Format")
    pcall(vim.keymap.del, "n", "<leader>cf")
    pcall(vim.api.nvim_buf_delete, env.bufnr, { force = true })
    for i = #restores, 1, -1 do
      restores[i]()
    end
    package.loaded["user.format"] = nil
  end
  return env
end

cases("formats named buffers", {
  {
    name = "Markdown extension",
    filename = "/workspace/src/readme.md",
    filetype = "",
    command = { "hongdown", "-" },
  },
  {
    name = "long Markdown extension",
    filename = "/workspace/src/readme.markdown",
    filetype = "",
    command = { "hongdown", "-" },
  },
  {
    name = "Markdown filetype",
    filename = "/workspace/src/README",
    filetype = "markdown",
    command = { "hongdown", "-" },
  },
  {
    name = "MDX extension",
    filename = "/workspace/src/page.mdx",
    filetype = "",
    command = { "hongdown", "--mdx", "-" },
  },
  {
    name = "compound MDX filetype",
    filename = "/workspace/src/page.txt",
    filetype = "markdown.mdx",
    command = { "hongdown", "--mdx", "-" },
  },
  {
    name = "TOML extension",
    filename = "/workspace/src/config.toml",
    filetype = "",
    command = {
      "taplo",
      "format",
      "--colors",
      "never",
      "--stdin-filepath",
      "/workspace/src/config.toml",
      "-",
    },
  },
  {
    name = "TOML filetype",
    filename = "/workspace/src/config",
    filetype = "toml",
    command = {
      "taplo",
      "format",
      "--colors",
      "never",
      "--stdin-filepath",
      "/workspace/src/config",
      "-",
    },
  },
  {
    name = "Lua extension",
    filename = "/workspace/src/config.LUA",
    filetype = "",
    command = {
      "stylua",
      "--search-parent-directories",
      "--stdin-filepath",
      "/workspace/src/config.LUA",
      "-",
    },
  },
  {
    name = "Lua filetype",
    filename = "/workspace/src/config",
    filetype = "lua",
    command = {
      "stylua",
      "--search-parent-directories",
      "--stdin-filepath",
      "/workspace/src/config",
      "-",
    },
  },
  {
    name = "dprint configuration discovery",
    filename = "/workspace/src/main.ts",
    filetype = "typescript",
    command = { "dprint", "fmt", "--stdin", "/workspace/src/main.ts" },
  },
  {
    name = "arbitrary dprint extension",
    filename = "/workspace/src/page.vue",
    filetype = "vue",
    command = { "dprint", "fmt", "--stdin", "/workspace/src/page.vue" },
  },
  {
    name = "file without an extension",
    filename = "/workspace/src/Dockerfile",
    filetype = "dockerfile",
    command = { "dprint", "fmt", "--stdin", "/workspace/src/Dockerfile" },
  },
  {
    name = "file name with spaces",
    filename = "/workspace/src/my file.json",
    filetype = "json",
    command = { "dprint", "fmt", "--stdin", "/workspace/src/my file.json" },
  },
}, function(env, case)
  vim.api.nvim_buf_set_name(env.bufnr, case.filename)
  vim.bo[env.bufnr].filetype = case.filetype

  vim.cmd.Format()

  equal(case.command, env.jobs[1].command)
  equal(
    { cwd = "/workspace/src", stdin = "const value=1" },
    env.jobs[1].options
  )
  equal({ "formatted" }, vim.api.nvim_buf_get_lines(env.bufnr, 0, -1, false))
  equal({}, env.notices)
end)

cases("formats unnamed buffers by filetype", {
  {
    name = "Markdown",
    filetype = "markdown",
    command = { "hongdown", "-" },
  },
  {
    name = "MDX",
    filetype = "mdx",
    command = { "hongdown", "--mdx", "-" },
  },
  {
    name = "TOML",
    filetype = "toml",
    command = { "taplo", "format", "--colors", "never", "-" },
  },
  {
    name = "Lua",
    filetype = "lua",
    command = { "stylua", "--search-parent-directories", "-" },
  },
  {
    name = "JavaScript",
    filetype = "javascript",
    command = { "dprint", "fmt", "--stdin", "js" },
  },
  {
    name = "JSX",
    filetype = "javascriptreact",
    command = { "dprint", "fmt", "--stdin", "jsx" },
  },
  {
    name = "TypeScript",
    filetype = "typescript",
    command = { "dprint", "fmt", "--stdin", "ts" },
  },
  {
    name = "TSX",
    filetype = "typescriptreact",
    command = { "dprint", "fmt", "--stdin", "tsx" },
  },
  {
    name = "JSONC",
    filetype = "jsonc",
    command = { "dprint", "fmt", "--stdin", "jsonc" },
  },
  {
    name = "other filetypes",
    filetype = "css",
    command = { "dprint", "fmt", "--stdin", "css" },
  },
}, function(env, case)
  vim.api.nvim_buf_set_name(env.bufnr, "")
  vim.bo[env.bufnr].filetype = case.filetype

  vim.cmd.Format()

  equal(case.command, env.jobs[1].command)
  equal({ cwd = "/startup", stdin = "const value=1" }, env.jobs[1].options)
  equal({ "formatted" }, vim.api.nvim_buf_get_lines(env.bufnr, 0, -1, false))
  equal({}, env.notices)
end)

cases("reports a missing executable without changing the buffer", {
  {
    name = "Hongdown",
    filename = "/workspace/src/readme.md",
    filetype = "markdown",
    executable = "hongdown",
    message = "hongdown not found in PATH",
  },
  {
    name = "Taplo",
    filename = "/workspace/src/config.toml",
    filetype = "toml",
    executable = "taplo",
    message = "taplo not found in PATH",
  },
  {
    name = "StyLua",
    filename = "/workspace/src/config.lua",
    filetype = "lua",
    executable = "stylua",
    message = "stylua not found in PATH",
  },
  {
    name = "dprint",
    filename = "/workspace/src/main.ts",
    filetype = "typescript",
    executable = "dprint",
    message = "dprint not found in PATH",
  },
}, function(env, case)
  vim.api.nvim_buf_set_name(env.bufnr, case.filename)
  vim.bo[env.bufnr].filetype = case.filetype
  env.executables[case.executable] = nil

  vim.cmd.Format()

  equal({}, env.jobs)
  equal(
    { { message = case.message, level = vim.log.levels.WARN } },
    env.notices
  )
  equal(
    { "const value=1" },
    vim.api.nvim_buf_get_lines(env.bufnr, 0, -1, false)
  )
end)

cases("reports dprint errors without a retry or configuration override", {
  {
    name = "invalid project configuration",
    result = { code = 1, stdout = "discard this", stderr = "Invalid config\n" },
    message = "dprint failed: Invalid config",
  },
  {
    name = "missing configuration",
    result = { code = 1, stdout = "", stderr = "No configuration found" },
    message = "dprint failed: No configuration found",
  },
  {
    name = "missing plugins",
    result = { code = 1, stdout = "", stderr = "No plugins found" },
    message = "dprint failed: No plugins found",
  },
  {
    name = "timeout",
    result = { code = 124, stdout = "", stderr = "" },
    message = "dprint failed",
  },
}, function(env, case)
  env.result = case.result

  vim.cmd.Format()

  equal(1, #env.jobs)
  equal(
    { "dprint", "fmt", "--stdin", "/workspace/src/main.ts" },
    env.jobs[1].command
  )
  equal(
    { { message = case.message, level = vim.log.levels.ERROR } },
    env.notices
  )
  equal(
    { "const value=1" },
    vim.api.nvim_buf_get_lines(env.bufnr, 0, -1, false)
  )
end)

test("requires a filetype for an unnamed buffer", function(env)
  vim.api.nvim_buf_set_name(env.bufnr, "")
  vim.bo[env.bufnr].filetype = ""

  vim.cmd.Format()

  equal({}, env.jobs)
  equal({
    {
      message = "dprint: set a file name or filetype before formatting",
      level = vim.log.levels.INFO,
    },
  }, env.notices)
  equal(
    { "const value=1" },
    vim.api.nvim_buf_get_lines(env.bufnr, 0, -1, false)
  )
end)

cases("does not replace the buffer unnecessarily", {
  { name = "unchanged output", stdout = "const value=1\n" },
  { name = "empty output", stdout = "" },
}, function(env, case)
  env.result.stdout = case.stdout
  local changedtick = vim.api.nvim_buf_get_changedtick(env.bufnr)

  vim.cmd.Format()

  equal(changedtick, vim.api.nvim_buf_get_changedtick(env.bufnr))
  equal(
    { "const value=1" },
    vim.api.nvim_buf_get_lines(env.bufnr, 0, -1, false)
  )
  equal({}, env.notices)
end)

test("formats unsaved text and preserves the cursor", function(env)
  vim.api.nvim_buf_set_lines(env.bufnr, 0, -1, false, {
    "const one=1",
    "const two=2",
    "console.log(one+two)",
  })
  vim.api.nvim_win_set_cursor(0, { 3, 2 })
  env.result.stdout =
    "const one = 1;\nconst two = 2;\nconsole.log(one + two);\n"

  vim.cmd.Format()

  equal(
    "const one=1\nconst two=2\nconsole.log(one+two)",
    env.jobs[1].options.stdin
  )
  equal({
    "const one = 1;",
    "const two = 2;",
    "console.log(one + two);",
  }, vim.api.nvim_buf_get_lines(env.bufnr, 0, -1, false))
  equal({ 3, 2 }, vim.api.nvim_win_get_cursor(0))
  equal(5000, env.jobs[1].timeout_ms)
end)

test("formats through the existing key mapping", function(env)
  local mapping = vim.fn.maparg("\\cf", "n", false, true)

  mapping.callback()

  equal(
    { "dprint", "fmt", "--stdin", "/workspace/src/main.ts" },
    env.jobs[1].command
  )
  equal({ "formatted" }, vim.api.nvim_buf_get_lines(env.bufnr, 0, -1, false))
end)

local failed = 0
for _, case in ipairs(tests) do
  local env = setup()
  local ok, err = xpcall(function()
    case.run(env)
  end, debug.traceback)
  env.cleanup()
  if ok then
    print("PASS " .. case.name)
  else
    failed = failed + 1
    io.stderr:write("FAIL " .. case.name .. "\n" .. err .. "\n")
  end
end

assert(failed == 0, failed .. " formatter tests failed")
print(#tests .. " formatter tests passed")
