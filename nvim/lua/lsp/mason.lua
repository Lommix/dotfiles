local status_ok, mason = pcall(require, "mason")
if not status_ok then
	return
end

local status_ok_1, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok_1 then
	return
end
local status_ok_2, lsp_config = pcall(require, "lspconfig")
if not status_ok_2 then
	return
end
-- custom
lsp_config.gdscript.setup({})
--lsp_config.intelephense.setup{}

local servers = {
	"cssls",
	"cssmodules_ls",
	"emmet_ls",
	"html",
	"jdtls",
	"jsonls",
	"sumneko_lua",
	"tflint",
	"terraformls",
	"tsserver",
	"pyright",
	"yamlls",
	"bashls",
	"clangd",
}

local settings = {
	ui = {
		border = "rounded",
		icons = {
			package_installed = "◍",
			package_pending = "◍",
			package_uninstalled = "◍",
		},
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4,
}
mason.setup(settings)
mason_lspconfig.setup({
	ensure_installed = servers,
	automatic_installation = true,
})

mason_lspconfig.setup_handlers({
	function(server_name)
		lsp_config[server_name].setup({})
	end,
	["sumneko_lua"] = function()
		local luadev = require("lua-dev").setup()
		lsp_config.sumneko_lua.setup(luadev)
	end,
})
