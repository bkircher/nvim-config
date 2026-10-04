-- Run from the repository root: nvim --clean -i NONE --headless -l tests/lsp.lua
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
    cwd = "/startup",
    root = "/workspace",
    executables = { ["/workspace/node_modules/.bin/tsc"] = 1 },
    enabled = { tsc = true },
    configs = {},
    clients = {},
    jobs = {},
    launches = {},
    notices = {},
    completions = {},
    buffers = {},
  }
  local restores = {}

  local function stub(object, key, value)
    local original = object[key]
    restores[#restores + 1] = function()
      object[key] = original
    end
    object[key] = value
  end

  stub(vim.uv, "cwd", function()
    return env.cwd
  end)
  stub(vim.fs, "root", function()
    return env.root
  end)
  stub(vim.fn, "executable", function(path)
    return env.executables[path] or 0
  end)
  stub(vim, "schedule", function(callback)
    callback()
  end)
  stub(vim, "notify", function(message, level)
    env.notices[#env.notices + 1] = { message = message, level = level }
  end)
  stub(vim, "system", function(command, options, on_exit)
    if env.spawn_error then
      error(env.spawn_error)
    end
    env.jobs[#env.jobs + 1] = {
      command = command,
      options = options,
      finish = on_exit,
    }
    return {}
  end)
  stub(vim.lsp.rpc, "start", function(command, _, options)
    if env.launch_error then
      error(env.launch_error)
    end
    env.launches[#env.launches + 1] = {
      command = command,
      options = options,
    }
    return {}
  end)
  stub(vim.lsp, "config", function(name, config)
    env.configs[name] = config
  end)
  stub(vim.lsp, "enable", function(names)
    for _, name in ipairs(names) do
      env.enabled[name] = true
    end
  end)
  stub(vim.lsp, "is_enabled", function(name)
    return env.enabled[name] == true
  end)
  stub(vim.lsp, "get_client_by_id", function(id)
    return env.clients[id]
  end)
  stub(vim.lsp.completion, "enable", function(enabled, id, bufnr, options)
    env.completions[#env.completions + 1] = {
      enabled = enabled,
      id = id,
      bufnr = bufnr,
      options = options,
    }
  end)

  package.loaded["user.lsp"] = nil
  package.loaded["user.lsp.tsc"] = nil

  env.cleanup = function()
    pcall(vim.api.nvim_del_augroup_by_name, "user_lsp")
    for _, bufnr in ipairs(env.buffers) do
      pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    end
    for i = #restores, 1, -1 do
      restores[i]()
    end
    package.loaded["user.lsp"] = nil
    package.loaded["user.lsp.tsc"] = nil
  end
  return env
end

local function buffer(env, filename, filetype)
  local bufnr = vim.api.nvim_create_buf(false, false)
  env.buffers[#env.buffers + 1] = bufnr
  if filename ~= "" then
    vim.api.nvim_buf_set_name(bufnr, filename)
  end
  vim.bo[bufnr].filetype = filetype or "typescript"
  return bufnr
end

local function activate(config, bufnr)
  local roots = {}
  config.root_dir(bufnr, function(root)
    roots[#roots + 1] = root
  end)
  return roots
end

local function version(env, output, code)
  env.jobs[1].finish({ code = code or 0, stdout = output, stderr = "" })
end

test("requires a workspace and supports all four file types", function()
  local config = require("user.lsp.tsc")

  equal(true, config.workspace_required)
  equal({
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  }, config.filetypes)
end)

test("uses the file's Git root instead of the startup directory", function(env)
  local config = require("user.lsp.tsc")
  local bufnr = buffer(env, "/workspace/packages/app/src/main.ts")

  local roots = activate(config, bufnr)
  version(env, "Version 7.0.2\n")

  equal({ "/workspace" }, roots)
  equal({
    "/workspace/node_modules/.bin/tsc",
    "--version",
  }, env.jobs[1].command)
  equal(
    { cwd = "/workspace", text = true, timeout = 2000 },
    env.jobs[1].options
  )
end)

test(
  "keeps the startup fallback after the working directory changes",
  function(env)
    env.root = nil
    env.executables["/startup/node_modules/.bin/tsc"] = 1
    local config = require("user.lsp.tsc")
    local bufnr = buffer(env, "/startup/src/main.ts")
    env.cwd = "/changed"

    local roots = activate(config, bufnr)
    version(env, "Version 7.0.2")

    equal({ "/startup" }, roots)
    equal("/startup", env.jobs[1].options.cwd)
  end
)

cases("does not use the startup server outside its directory", {
  { name = "unrelated directory", filename = "/outside/main.ts" },
  { name = "same path prefix", filename = "/startup-other/main.ts" },
}, function(env, case)
  env.root = nil
  env.executables["/startup/node_modules/.bin/tsc"] = 1
  local config = require("user.lsp.tsc")
  local bufnr = buffer(env, case.filename)

  local roots = activate(config, bufnr)

  equal({}, roots)
  equal({}, env.jobs)
end)

cases("skips buffers that do not represent files", {
  { name = "unnamed", filename = "", buftype = "" },
  { name = "scratch", filename = "/workspace/scratch.ts", buftype = "nofile" },
}, function(env, case)
  local config = require("user.lsp.tsc")
  local bufnr = buffer(env, case.filename)
  vim.bo[bufnr].buftype = case.buftype

  local roots = activate(config, bufnr)

  equal({}, roots)
  equal({}, env.jobs)
end)

test(
  "never selects a global, parent, package-local, or tsgo executable",
  function(env)
    env.executables = {
      tsc = 1,
      tsgo = 1,
      ["/node_modules/.bin/tsc"] = 1,
      ["/workspace/packages/app/node_modules/.bin/tsc"] = 1,
      ["/workspace/node_modules/.bin/tsgo"] = 1,
    }
    local config = require("user.lsp.tsc")
    local bufnr = buffer(env, "/workspace/packages/app/main.ts")

    local roots = activate(config, bufnr)

    equal({}, roots)
    equal({}, env.jobs)
    equal({}, env.notices)
  end
)

cases("accepts supported TypeScript versions", {
  { name = "TypeScript 7", output = "Version 7.0.2\n" },
  { name = "later major version", output = "Version 8.0.0\n" },
  {
    name = "native development build",
    output = "Version 7.1.0-dev.20260929.1\n",
  },
}, function(env, case)
  local config = require("user.lsp.tsc")
  local bufnr = buffer(env, "/workspace/main.ts")

  local roots = activate(config, bufnr)
  version(env, case.output)

  equal({ "/workspace" }, roots)
  equal({}, env.notices)
end)

cases("rejects unsupported or failed version checks", {
  { name = "TypeScript 6", output = "Version 6.0.3", code = 0 },
  { name = "invalid output", output = "not a version", code = 0 },
  { name = "failed command", output = "Version 7.0.2", code = 1 },
  { name = "timeout", output = "", code = 124 },
}, function(env, case)
  env.executables.tsc = 1
  local config = require("user.lsp.tsc")
  local bufnr = buffer(env, "/workspace/main.ts")

  local roots = activate(config, bufnr)
  version(env, case.output, case.code)
  local retry = activate(config, bufnr)

  equal({}, roots)
  equal({}, retry)
  equal(1, #env.jobs)
  equal(1, #env.notices)
  equal(vim.log.levels.WARN, env.notices[1].level)
  assert(
    env.notices[1].message:find("/workspace/node_modules/.bin/tsc", 1, true)
  )
end)

test("reports a version process creation error once", function(env)
  env.spawn_error = "test process creation failure"
  local config = require("user.lsp.tsc")
  local bufnr = buffer(env, "/workspace/main.ts")

  local roots = activate(config, bufnr)
  local retry = activate(config, bufnr)

  equal({}, roots)
  equal({}, retry)
  equal(1, #env.notices)
  assert(env.notices[1].message:find("test process creation failure", 1, true))
end)

test("shares an asynchronous version check and caches its result", function(env)
  local config = require("user.lsp.tsc")
  local first = buffer(env, "/workspace/first.ts")
  local second = buffer(env, "/workspace/second.ts")
  local third = buffer(env, "/workspace/third.ts")

  local first_roots = activate(config, first)
  local second_roots = activate(config, second)

  equal({}, first_roots)
  equal({}, second_roots)
  equal(1, #env.jobs)

  version(env, "Version 7.0.2")
  local third_roots = activate(config, third)

  equal({ "/workspace" }, first_roots)
  equal({ "/workspace" }, second_roots)
  equal({ "/workspace" }, third_roots)
  equal(1, #env.jobs)
end)

test("checks separate workspaces independently", function(env)
  env.executables["/other/node_modules/.bin/tsc"] = 1
  local config = require("user.lsp.tsc")
  local first = buffer(env, "/workspace/main.ts")
  local second = buffer(env, "/other/main.ts")

  local first_roots = activate(config, first)
  env.root = "/other"
  local second_roots = activate(config, second)
  version(env, "Version 6.0.3")
  env.jobs[2].finish({ code = 0, stdout = "Version 7.0.2", stderr = "" })

  equal({}, first_roots)
  equal({ "/other" }, second_roots)
  equal({ "/other/node_modules/.bin/tsc", "--version" }, env.jobs[2].command)
  equal(1, #env.notices)
end)

cases("does not attach a stale buffer after a pending check", {
  {
    name = "deleted buffer",
    change = function(_, bufnr)
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end,
  },
  {
    name = "renamed buffer",
    change = function(_, bufnr)
      vim.api.nvim_buf_set_name(bufnr, "/other/main.ts")
    end,
  },
  {
    name = "changed file type",
    change = function(_, bufnr)
      vim.bo[bufnr].filetype = "lua"
    end,
  },
  {
    name = "disabled server",
    change = function(env)
      env.enabled.tsc = false
    end,
  },
}, function(env, case)
  local config = require("user.lsp.tsc")
  local bufnr = buffer(env, "/workspace/main.ts")

  local roots = activate(config, bufnr)
  case.change(env, bufnr)
  version(env, "Version 7.0.2")

  equal({}, roots)
end)

test(
  "launches the root-local server with stdio and the workspace cwd",
  function(env)
    local config = require("user.lsp.tsc")

    config.cmd({}, { root_dir = "/workspace with spaces" })

    equal({
      {
        command = {
          "/workspace with spaces/node_modules/.bin/tsc",
          "--lsp",
          "--stdio",
        },
        options = { cwd = "/workspace with spaces" },
      },
    }, env.launches)
  end
)

test(
  "does not retry a server process creation error on another buffer",
  function(env)
    local config = require("user.lsp.tsc")
    local bufnr = buffer(env, "/workspace/main.ts")
    activate(config, bufnr)
    version(env, "Version 7.0.2")
    env.launch_error = "test server process creation failure"

    local ok = pcall(config.cmd, {}, { root_dir = "/workspace" })
    local retry = activate(config, bufnr)

    equal(false, ok)
    equal({}, retry)
    equal(1, #env.jobs)
  end
)

cases("handles server exits without a retry loop", {
  { name = "error exit", code = 1, signal = 0, roots = {} },
  { name = "crash", code = 0, signal = 11, roots = {} },
  { name = "normal exit", code = 0, signal = 0, roots = { "/workspace" } },
  { name = "termination", code = 0, signal = 15, roots = { "/workspace" } },
}, function(env, case)
  local config = require("user.lsp.tsc")
  local bufnr = buffer(env, "/workspace/main.ts")
  env.clients[42] = { config = { root_dir = "/workspace" } }
  activate(config, bufnr)
  version(env, "Version 7.0.2")

  config.on_exit(case.code, case.signal, 42)
  local roots = activate(config, bufnr)

  equal(case.roots, roots)
  equal(1, #env.jobs)
end)

test("registers TypeScript without disabling other servers", function(env)
  env.enabled = { other = true }

  require("user.lsp")

  equal(true, env.enabled.tsc)
  equal(true, env.enabled.other)
  equal({ "tsc" }, vim.tbl_keys(env.configs))
  equal(true, env.configs.tsc.workspace_required)
end)

test("enables manual completion for each attached client", function(env)
  local bufnr = buffer(env, "/workspace/main.ts")
  env.clients[1] = {
    id = 1,
    supports_method = function(_, method)
      return method == "textDocument/completion"
    end,
  }
  env.clients[2] = {
    id = 2,
    supports_method = function(_, method)
      return method == "textDocument/completion"
    end,
  }
  require("user.lsp")

  vim.api.nvim_exec_autocmds(
    "LspAttach",
    { buffer = bufnr, data = { client_id = 1 } }
  )
  vim.api.nvim_exec_autocmds(
    "LspAttach",
    { buffer = bufnr, data = { client_id = 2 } }
  )

  equal({
    {
      enabled = true,
      id = 1,
      bufnr = bufnr,
      options = { autotrigger = false },
    },
    {
      enabled = true,
      id = 2,
      bufnr = bufnr,
      options = { autotrigger = false },
    },
  }, env.completions)
end)

test("skips completion for unsupported or missing clients", function(env)
  local bufnr = buffer(env, "/workspace/main.ts")
  env.clients[1] = {
    id = 1,
    supports_method = function()
      return false
    end,
  }
  require("user.lsp")

  vim.api.nvim_exec_autocmds(
    "LspAttach",
    { buffer = bufnr, data = { client_id = 1 } }
  )
  vim.api.nvim_exec_autocmds(
    "LspAttach",
    { buffer = bufnr, data = { client_id = 2 } }
  )

  equal({}, env.completions)
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

assert(failed == 0, failed .. " LSP tests failed")
print(#tests .. " LSP tests passed")
