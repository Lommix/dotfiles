return {
	{
		"folke/trouble.nvim",
		config = function()
			require("trouble").setup({})
			vim.keymap.set("n", "gn", ":Trouble diagnostics toggle focus<Cr>", {
				silent = true,
			})
		end,
		opts = {},
		cmd = "Trouble",
		keys = {},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		lazy = true,
		opts = {
			signs = true, -- show icons in the signs column
			sign_priority = 8, -- sign priority
			keywords = {
				FIX = { icon = " ", color = "error", alt = { "fix" } },
				TODO = { icon = " ", color = "info", alt = { "todo" } },
				HACK = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
		},
		keys = {
			{ "gf", ":TodoLocList<CR>", mode = "n" },
		},
	},
}
