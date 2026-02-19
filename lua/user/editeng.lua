-- English text editor
-- Sends a visual selection to gemini with an English editing prompt and
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

local function gemini_supported()
  return vim.fn.executable("gemini") == 1
end

local function edit_selection(opts)
  if not gemini_supported() then
    vim.notify("gemini not found in PATH", vim.log.levels.WARN)
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

  vim.notify("Editing with gemini…")

  local cmd = {
    "gemini",
    "-p",
    system_prompt,
    "-s",
    "-o",
    "json",
  }

  vim.system(
    cmd,
    {
      stdin = selected_text,
      text = true,
      env = { NODE_OPTIONS = "--no-deprecation" },
    },
    function(res)
      vim.schedule(function()
        if res.code ~= 0 or not res.stdout or res.stdout == "" then
          local err = res.stderr and vim.trim(res.stderr) or ""
          local msg = "gemini failed"
          if err ~= "" then
            msg = msg .. ": " .. err
          end
          vim.notify(msg, vim.log.levels.ERROR)
          return
        end
        local ok, parsed = pcall(vim.json.decode, res.stdout)
        if not ok or not parsed or not parsed.response then
          vim.notify("gemini: unexpected output", vim.log.levels.ERROR)
          return
        end
        local text = vim.trim(parsed.response)
        if text == "" then
          vim.notify("gemini returned empty response", vim.log.levels.WARN)
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
    end
  )
end

vim.api.nvim_create_user_command(
  "EditEng",
  edit_selection,
  { range = true, desc = "Edit selected text with gemini English editor" }
)
