-- Initialize nvim-treesitter (guard if plugin is missing)
local ok, configs = pcall(require, 'nvim-treesitter.configs')
if ok then
  configs.setup({
    -- Note: ensure_installed triggers installation of parsers for listed
    -- languages. Keep this list minimal and controlled; set
    -- auto_install/sync_install to false.
    ensure_installed = {
      "c",
      "lua",
      "vimdoc",
      "python",
      "javascript",
      "markdown",
      "elixir",
    },
    auto_install = false,
    sync_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
  })
end
