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

require("lommix.options")

vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")

-- custom
require("lommix.keybinds")
require("lommix.notes")
require("lommix.rel_path")
require("lommix.auto")
require("lommix.spell")

-- Colorscheme
vim.cmd("colorscheme lommix_ghost")
