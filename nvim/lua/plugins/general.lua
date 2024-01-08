return {
	"nvim-tree/nvim-web-devicons",
	{ "nvim-lua/plenary.nvim", name = "plenary", priority = 9999 },
	{ "MunifTanjim/nui.nvim",  name = "nui",     priority = 9999 },
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					["C-q"] = "actions.close",
				},
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"weilbith/nvim-code-action-menu",
		config = function()
		end
	}
}
