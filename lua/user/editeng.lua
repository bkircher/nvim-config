-- English text editor
-- Sends a visual selection to opencode with an English editing prompt and
-- replaces the selection with the corrected text.

local system_prompt = [[You are an English text editor.

Instructions:
- Follow user requirements exactly.
- Provide concise, logical, and clear suggestions.
- Keep responses brief, impersonal, and focused.
- For spelling or grammar corrections, default to US English unless otherwise specified. If British English variants are present, use them consistently.
- Offer specific, targeted suggestions for improvement instead of rewriting the entire text.

Always apply these rules when identifying and suggesting corrections for English text.

Return only the corrected text, no explanations or commentary.]]

local function opencode_supported()
  return vim.fn.executable("opencode") == 1
end

local function edit_selection(opts)
  if not opencode_supported() then
    vim.notify("opencode not found in PATH", vim.log.levels.WARN)
    return
  end

  local start_line = opts.line1
  local end_line = opts.line2
  local bufnr = vim.api.nvim_get_current_buf()
  local lines =
    vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  local selected_text = table.concat(lines, "\n")

  if vim.trim(selected_text) == "" then
    vim.notify("No text selected", vim.log.levels.INFO)
    return
  end

  vim.notify("Editing with opencode…")

  local prompt = system_prompt .. "\n\nText:\n" .. selected_text
  local cmd = {
    "opencode",
    "run",
    prompt,
  }

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
      local replacement = vim.split(text, "\n", { plain = true })
      vim.api.nvim_buf_set_lines(
        bufnr,
        start_line - 1,
        end_line,
        false,
        replacement
      )
    end)
  end)
end

vim.api.nvim_create_user_command(
  "EditEng",
  edit_selection,
  { range = true, desc = "Edit selected text with opencode English editor" }
)
