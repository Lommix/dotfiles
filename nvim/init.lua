local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lommix.options")
require("lommix.keybinds")
require("lommix.auto")
require("lommix.notes")

require("lazy").setup("plugins")

-- Colorscheme
vim.cmd("colorscheme monokai-pro-machine")
