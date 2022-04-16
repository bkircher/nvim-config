local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim.git",
    install_path,
  }
  vim.notify("Installing packer. Close and reopen Neovim…")
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads Neovim whenever you save plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lus source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local ok, packer = pcall(require, "packer")
if not ok then
  vim.notify("plugins.lua: require packer didn't work")
  return
end

-- Have packer use a floating popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install plugins here
return packer.startup(function(use)
  use "wbthomason/packer.nvim" -- Have packer manage itself

  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)