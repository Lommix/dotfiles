return {
	"nvim-treesitter/playground",
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter.configs")

			ts.setup({
				ensure_installed = { "tsx", "toml", "xml", "twig", "php", "json", "yaml", "css", "go", "rust", "html", "lua", "gdscript", "dockerfile", "javascript", "godot_resource", "markdown", "markdown_inline" },
				sync_install = false,
				auto_install = false,
				highlight = { enable = true },
				indent = { enable = true, disable = {} },
				ignore_install = {},
			})

			vim.filetype.add({ extension = { wgsl = "wgsl" } })

			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.wgsl = {
				install_info = {
					url = "https://github.com/szebniok/tree-sitter-wgsl",
					files = { "src/parser.c" }
				},
			}
			parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
		end
	}
}
