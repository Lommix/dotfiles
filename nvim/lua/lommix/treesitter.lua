local status, ts = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

ts.setup({
	ensure_installed = { "tsx", "toml", "json","xml", "twig", "php", "json", "yaml", "css", "go", "rust", "html", "lua", "gdscript", "dockerfile", "javascript", "godot_resource", "markdown", "markdown_inline" },
	sync_install = false,
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true, disable = {}},
})

vim.filetype.add({extension = {wgsl = "wgsl"}})

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.wgsl = {
    install_info = {
        url = "https://github.com/szebniok/tree-sitter-wgsl",
        files = {"src/parser.c"}
    },
}
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
