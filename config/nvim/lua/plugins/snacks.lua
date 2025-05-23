return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		input = { enabled = true },
		indent = {
			chunk = { enabled = true },
		},
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scroll = { enabled = false },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		image = {
			doc = {
				inline = vim.g.neovim_mode == "skitty" and true or false,
				float = true,
			},
		},
	},
}
