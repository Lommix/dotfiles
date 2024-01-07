return {
	"stevearc/oil.nvim",
	lazy = false,
	keys = {
		{"<leader>e", ":Oil<CR>"}
	},
	config = function()
		require("oil").setup()
	end,
}
