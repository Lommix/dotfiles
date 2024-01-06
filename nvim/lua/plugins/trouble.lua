return {
	"folke/trouble.nvim",
	config = function()
		require("trouble").setup {
		}
	end,
	opts = {},
	keys = {
		{ "gf", ":TroubleToggle quickfix<CR>", mode = "n" },
		{ "gn", ":TroubleToggle workspace_diagnostics<CR>", mode = "n" },
	}
}
