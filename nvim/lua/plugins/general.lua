return {
	"nvim-tree/nvim-web-devicons",
	{ "nvim-lua/plenary.nvim", name = "plenary", priority = 9999 },
	{ "MunifTanjim/nui.nvim", name = "nui", priority = 9999 },
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
		"aznhe21/actions-preview.nvim",
		config = function() end,
	},
	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({})
		end,
	},
}
