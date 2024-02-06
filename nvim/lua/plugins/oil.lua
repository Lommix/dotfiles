return {
	"stevearc/oil.nvim",
	lazy = false,
	keys = {
		{ "<leader>e", ":Oil<CR>" },
	},
	config = function()
		require("oil").setup({
			view_options = {
				is_hidden_file = function(name, bufnr)
					local is_dotfile = vim.startswith(name, ".")
					local is_bk = vim.startswith(name, "~")
					return is_dotfile or is_bk
				end,
			},
		})
	end,
}
