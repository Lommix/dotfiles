return {
	"nvim-tree/nvim-web-devicons",
	"echasnovski/mini.icons",
	{ "nvim-lua/plenary.nvim", name = "plenary", priority = 9999 },
	{ "MunifTanjim/nui.nvim", name = "nui", priority = 9999 },
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({})
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

	{
		"dmtrKovalenko/fff.nvim",
		build = function()
			-- downloads a prebuilt binary or falls back to cargo build
			require("fff.download").download_or_build_binary()
		end,
		-- for nixos:
		-- build = "nix run .#release",
		opts = {
			debug = {
				enabled = true,
				show_scores = true,
			},
		},
		lazy = false, -- the plugin lazy-initialises itself
		keys = {
			{
				"ff",
				function()
					require("fff").find_files()
				end,
				desc = "FFFind files",
			},
			{
				"fg",
				function()
					require("fff").live_grep()
				end,
				desc = "LiFFFe grep",
			},
			{
				"fz",
				function()
					require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
				end,
				desc = "Live fffuzy grep",
			},
			{
				"fc",
				function()
					require("fff").live_grep({ query = vim.fn.expand("<cword>") })
				end,
				desc = "Search current word",
			},
		},
	},
}
