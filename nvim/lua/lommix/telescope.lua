require("telescope").load_extension("fzf")
require("telescope").setup({
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = false, -- override the generic sorter
			override_file_sorter = false, -- override the file sorter
			case_mode = "ignore_case", -- or "ignore_case" or "respect_case"
		},
	},
	defaults = {
		path_display = { "smart" },
		file_ignore_patterns = { ".png", ".jpg", ".svg", ".import", ".jepg" },
	},
})
