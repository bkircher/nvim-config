local group = vim.api.nvim_create_augroup("user_lsp", { clear = true })

-- Use manual completion for each client that supports it.
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  desc = "Enable built-in LSP completion",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if
      client and client:supports_method("textDocument/completion", args.buf)
    then
      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = false,
      })
    end
  end,
})

-- Each module returns a vim.lsp.Config with its own local server lookup.
local servers = { "tsc" }

for _, name in ipairs(servers) do
  vim.lsp.config(name, require("user.lsp." .. name))
end

vim.lsp.enable(servers)
