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

lsp_config.gdscript.setup({
	cmd = { "nc", "127.0.0.1", "6008" },
})

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
	"tailwindcss",
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

local opts = {
	on_attach = function(client, bufnr)
		require("lsp-inlayhints").on_attach(client, bufnr)
		--client.resolved_capabilities.document_formatting = false
	end,
}

mason_lspconfig.setup_handlers({
	function(server_name)
		lsp_config[server_name].setup(opts)
	end,
	-- ["html"] = function()
	-- 	lsp_config.html.setup(vim.tbl_extend("force", opts, {
	-- 		filetypes = { "html", "typescriptreact", "javascript", "twig", "php" },
	-- 		on_attach = function(client, bufnr)
	-- 			client.resolved_capabilities.document_formatting = false
	-- 		end,
	-- 	}))
	-- end,
	["sumneko_lua"] = function()
		local luadev = require("lua-dev").setup({
			lspconfig = {
				on_attach = opts.on_attach,
			},
		})
		lsp_config.sumneko_lua.setup(vim.tbl_deep_extend("force", luadev, {
			on_attach = function(client, bufnr)
				-- client.resolved_capabilities.document_formatting = false
			end,
		}))
	end,
})
