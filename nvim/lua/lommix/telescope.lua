local fzf = require("telescope").load_extension("fzf")
local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")

telescope.setup({
	extensions = {
		live_grep_args = {
			auto_quoting = false, -- enable/disable auto-quoting
			mappings = { -- extend mappings
				i = {
					["<C-k>"] = lga_actions.quote_prompt(),
					["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
				},
			},
		},
		fzf = {
			fuzzy = false, -- false will only do exact matching
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
