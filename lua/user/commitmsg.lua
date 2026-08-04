-- Generate git commit message
-- Invokes pi's git-commit-message skill and inserts the result at cursor.

local insertion_namespace = vim.api.nvim_create_namespace("user.commitmsg")

local function nvm_supported()
  local nvm_dir = vim.env.NVM_DIR or vim.fn.expand("~/.nvm")
  return vim.fn.filereadable(nvm_dir .. "/nvm.sh") == 1
end

local function seatbelt_supported()
  return vim.fn.executable("seatbelt") == 1
end

local function generate_commit_msg()
  if not nvm_supported() then
    vim.notify("nvm not found", vim.log.levels.WARN)
    return
  end

  if not seatbelt_supported() then
    vim.notify("seatbelt not found in PATH", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local buffer_path = vim.api.nvim_buf_get_name(bufnr)
  local git_root = buffer_path ~= "" and vim.fs.root(buffer_path, ".git")
  if not git_root then
    vim.notify("Current buffer is not in a Git repository", vim.log.levels.WARN)
    return
  end

  local staged_files = vim
    .system({ "git", "diff", "--staged", "--name-only" }, {
      cwd = git_root,
      text = true,
    })
    :wait()
  if
    staged_files.code ~= 0
    or not staged_files.stdout
    or vim.trim(staged_files.stdout) == ""
  then
    vim.notify("No staged changes", vim.log.levels.INFO)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local insertion_mark = vim.api.nvim_buf_set_extmark(
    bufnr,
    insertion_namespace,
    cursor[1] - 1,
    cursor[2],
    { right_gravity = true }
  )

  local function clear_insertion_mark()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_del_extmark(bufnr, insertion_namespace, insertion_mark)
    end
  end

  vim.notify("Generating commit message…")

  local prompt = "/skill:git-commit-message"

  local cmd = {
    vim.env.SHELL or "/bin/zsh",
    "-c",
    [[
      export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
      source "$NVM_DIR/nvm.sh" || exit 1
      nvm use --silent default || exit 1
      exec "$@"
    ]],
    "CommitMsg",
    "seatbelt",
    "run",
    "pi",
    "--print",
    "--model",
    "github-copilot/gpt-5.6-luna",
    "--tools",
    "bash",
    "--no-session",
    "--no-context-files",
    "--no-skills",
    "--skill",
    vim.fn.expand("~/.pi/agent/skills/git-commit-message/SKILL.md"),
  }

  vim.system(cmd, { cwd = git_root, text = true, stdin = prompt }, function(res)
    vim.schedule(function()
      if res.code ~= 0 or not res.stdout or res.stdout == "" then
        clear_insertion_mark()
        local err = res.stderr and vim.trim(res.stderr) or ""
        local msg = "pi failed"
        if err ~= "" then
          msg = msg .. ": " .. err
        end
        vim.notify(msg, vim.log.levels.ERROR)
        return
      end
      local text = vim.trim(res.stdout)
      if text == "" then
        clear_insertion_mark()
        vim.notify("pi returned empty response", vim.log.levels.WARN)
        return
      end
      if not vim.api.nvim_buf_is_valid(bufnr) then
        vim.notify("Original buffer no longer exists", vim.log.levels.WARN)
        return
      end
      local insertion_point = vim.api.nvim_buf_get_extmark_by_id(
        bufnr,
        insertion_namespace,
        insertion_mark,
        {}
      )
      clear_insertion_mark()
      if #insertion_point == 0 then
        vim.notify("Insertion point no longer exists", vim.log.levels.WARN)
        return
      end
      local lines = vim.split(text, "\n", { plain = true })
      vim.api.nvim_buf_set_text(
        bufnr,
        insertion_point[1],
        insertion_point[2],
        insertion_point[1],
        insertion_point[2],
        lines
      )
    end)
  end)
end

vim.api.nvim_create_user_command(
  "CommitMsg",
  generate_commit_msg,
  { desc = "Generate git commit message from staged changes" }
)
