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

local lsp_status = require("lsp-status")
lsp_status.register_progress()

lsp_config.gdscript.setup({
	cmd = { "nc", "127.0.0.1", "6005" },
})

local servers = {
	"cssls",
	"cssmodules_ls",
	"emmet_ls",
	"html",
	"jdtls",
	"jsonls",
	"lua_ls",
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
	capabilities = lsp_status.capabilities,
	on_attach = function(client, bufnr)
		require("lsp-inlayhints").on_attach(client, bufnr)
		lsp_status.on_attach(client)
		--client.resolved_capabilities.document_formatting = false
	end,
}

mason_lspconfig.setup_handlers({
	function(server_name)
		lsp_config[server_name].setup(opts)
	end,
	["html"] = function()
		lsp_config.html.setup(vim.tbl_extend("force", opts, {
			filetypes = { "html", "twig" },
		}))
	end,
	["vimls"] = function()
		lsp_config.vimls.setup({
			filetypes = { "js", "vue" },
		})
	end,
	["cssmodules_ls"] = function()
		lsp_config.cssmodules_ls.setup({
			filetypes = { "css", "scss", "less" },
			capabilities = opts.capabilities,
			on_attach = opts.on_attach,
		})
	end,
	["emmet_ls"] = function()
		lsp_config.emmet_ls.setup({
			filetypes = { "twig" },
		})
	end,
	["lua_ls"] = function()
		local luadev = require("lua-dev").setup({
			lspconfig = {
				on_attach = opts.on_attach,
			},
		})
		lsp_config.lua_ls.setup(vim.tbl_deep_extend("force", luadev, {
			on_attach = function(client, bufnr)
				-- client.resolved_capabilities.document_formatting = false
			end,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		}))
	end,
})
