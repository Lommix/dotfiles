return {
	"nvim-treesitter/playground",
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			priority = 9999,
			config = function()
				local ts = require("nvim-treesitter.configs")

				local list = {
					"tsx",
					"toml",
					"xml",
					"twig",
					"php",
					"json",
					"yaml",
					"css",
					"go",
					"rust",
					"html",
					"lua",
					"gdscript",
					"dockerfile",
					"javascript",
					"markdown",
					"markdown_inline",
				}

				ts.setup({
					sync_install = true,
					auto_install = true,
					highlight = { enable = true },
					indent = { enable = true }, -- this might fuck stuff up
				})

				vim.filetype.add({ extension = { wgsl = "wgsl" } })

				-- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
				--
				-- parser_config.wgsl = {
				-- 	install_info = {
				-- 		url = "https://github.com/szebniok/tree-sitter-wgsl",
				-- 		files = { "src/parser.c" }
				-- 	},
				-- }
				-- parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
			end,
		},
	},
}
