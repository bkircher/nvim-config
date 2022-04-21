local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
  return
end

configs.setup {
  ensure_installed = "all", -- One of "all", "maintained" (parsers with maintainers), or a list of parsers
  sync_install = false, -- Install parsers synchronously
  ignore_install = { "" }, -- List of parsers to ignore
  highlight = {
    enable = true, -- Enable highlighting by default
    disable = { "" }, -- List of parsers with highlighting disabled
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = {
      "yaml",
    },
  },
}
