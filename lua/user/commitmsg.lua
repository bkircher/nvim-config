-- Generate git commit message
-- Sends staged diff to opencode and inserts the resulting commit message
-- at cursor.

local function opencode_supported()
  return vim.fn.executable("opencode") == 1
end

local function generate_commit_msg()
  if not opencode_supported() then
    vim.notify("opencode not found in PATH", vim.log.levels.WARN)
    return
  end

  -- Grab staged diff first
  local diff = vim.fn.system({ "git", "diff", "--staged" })
  if vim.v.shell_error ~= 0 or not diff or vim.trim(diff) == "" then
    vim.notify("No staged changes", vim.log.levels.INFO)
    return
  end

  vim.notify("Generating commit message…")

  local prompt = "Write a concise Git commit message for these staged changes. "
    .. "Output only the commit message, nothing else.\n\n"
    .. diff

  local cmd = { "opencode", "run", prompt }

  vim.system(cmd, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 or not res.stdout or res.stdout == "" then
        local err = res.stderr and vim.trim(res.stderr) or ""
        local msg = "opencode failed"
        if err ~= "" then
          msg = msg .. ": " .. err
        end
        vim.notify(msg, vim.log.levels.ERROR)
        return
      end
      local text = vim.trim(res.stdout)
      if text == "" then
        vim.notify("opencode returned empty response", vim.log.levels.WARN)
        return
      end
      local lines = vim.split(text, "\n", { plain = true })
      vim.api.nvim_put(lines, "l", true, true)
    end)
  end)
end

vim.api.nvim_create_user_command(
  "CommitMsg",
  generate_commit_msg,
  { desc = "Generate git commit message from staged changes" }
)
