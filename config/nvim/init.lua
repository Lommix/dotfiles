local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

require("lommix.options")
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", {
	change_detection = {
		notify = false,
	},
})

-- custom
require("lommix.keybinds")
require("lommix.aseprite")
require("lommix.notes")
require("lommix.auto")
require("lommix.theme")
