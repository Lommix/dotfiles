return {
	"stevearc/oil.nvim",
	lazy = false,
	keys = {
		{"<leader>", ":Oil --float<CR>"}
	},
	config = function()
		require("oil").setup()
	end,
}
