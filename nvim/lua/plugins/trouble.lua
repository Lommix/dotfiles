return {
	"folke/trouble.nvim",
	config = function()
		require("trouble").setup {
		}
	end,
	keys = {
		{ "gx", ":TroubleToggle quickfix<CR>", mode = "n" }
	}
}
