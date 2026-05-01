-- Generate git commit message
-- Sends staged diff to pi and inserts the resulting commit message at cursor.

local function pi_supported()
  return vim.fn.executable("pi") == 1
end

local function generate_commit_msg()
  if not pi_supported() then
    vim.notify("pi not found in PATH", vim.log.levels.WARN)
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

  local cmd = {
    "pi",
    "--print",
    "--no-tools",
    "--no-session",
    "--no-context-files",
    "--system-prompt",
    "You are a Git commit message generator. Output only the commit message, nothing else. Rules:\n\n"
.. "1. Separate subject from body with a blank line\n"
.. "2. Limit the subject line to 50 characters\n"
.. "3. Capitalize the subject line\n"
.. "4. Do not end the subject line with a period\n"
.. "5. Use the imperative mood in the subject line\n"
.. "6. Wrap the body at 72 characters\n"
.. "7. Use the body to explain what and why vs. how",
  }

  vim.system(cmd, { text = true, stdin = prompt }, function(res)
    vim.schedule(function()
      if res.code ~= 0 or not res.stdout or res.stdout == "" then
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
        vim.notify("pi returned empty response", vim.log.levels.WARN)
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
