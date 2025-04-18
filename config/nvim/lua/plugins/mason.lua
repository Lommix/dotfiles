local servers = {
	"cssls",
	"cssmodules_ls",
	"emmet_ls",
	"html",
	"pyright",
	"bashls",
	"clangd",
	"sqlls",
}

return {
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			local mason_lspconfig = require("mason-lspconfig")
			local lsp_config = require("lspconfig")

			mason_lspconfig.setup({
				ensure_installed = servers,
				automatic_installation = true,
			})

			local icons = require("lommix.icons")
			local lsp_status = require("lsp-status")

			local handler_opts = {
				capabilities = lsp_status.capabilities,
				on_attach = function(client, bufnr)
					-- require("lsp-inlayhints").on_attach(client, bufnr)
					lsp_status.on_attach(client)
					-- vim.lsp.inlay_hint.enable(true)
				end,
			}

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			local signs = {
				{ name = "DiagnosticSignError", text = icons.diagnostics.Error },
				{ name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
				{ name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
				{ name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
			}

			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
			end

			local config = {
				virtual_lines = true,
				virtual_text = false,
				-- virtual_text = {
				-- 	prefix = icons.ui.Gear,
				-- 	severity = vim.diagnostic.severity.ERROR,
				-- },
				signs = {
					active = signs,
				},
				update_in_insert = true,
				underline = true,
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
					width = 40,
				},
			}

			vim.diagnostic.config(config)

			local handlers = {
				function(server_name)
					lsp_config[server_name].setup(handler_opts)
				end,
				["zls"] = function()
					lsp_config.zls.setup({
						settings = {
							force_autofix = true,
							enable_build_on_save = true,
							highlight_global_var_declarations = true,
							dangerous_comptime_experiments_do_not_enable = true,
							inlay_hints_hide_redundant_param_names_last_token = true,
							include_at_in_builtins = true,
						},
					})
				end,
				["rust_analyzer"] = function()
					lsp_config.rust_analyzer.setup(vim.tbl_extend("force", handler_opts, {
						settings = {
							["rust-analyzer"] = {
								diagnostics = {
									enable = false,
								},
							},
						},
					}))
				end,
				["lemminx"] = function()
					lsp_config.lemminx.setup(vim.tbl_extend("force", handler_opts, {
						filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
						single_file_support = true,
						settings = {
							xml = {
								trace = {
									server = "verbose",
								},
								logs = {
									client = true,
								},
								format = {
									splitAttributes = "alignWithFirstAttr",
									joinContentLines = true,
									preservedNewlines = 1,
									insertSpaces = true,
									tabSize = 4,
								},
							},
						},
					}))
				end,
				["wgsl_analyzer"] = function()
					lsp_config.wgsl_analyzer.setup(vim.tbl_extend("force", handler_opts, {
						filetypes = { "wgsl" },
					}))
				end,
				["html"] = function()
					lsp_config.html.setup(vim.tbl_extend("force", handler_opts, {
						filetypes = { "html", "twig", "templ", "htmldjango", "javascript" },
					}))
				end,
				["htmx"] = function()
					lsp_config.htmx.setup(vim.tbl_extend("force", handler_opts, {
						filetypes = { "html", "templ", "twig" },
					}))
				end,
				["cssls"] = function()
					local caps = handler_opts.capabilities
					caps.textDocument.completion.completionItem.snippetSupport = true
					lsp_config.cssls.setup(vim.tbl_extend("force", handler_opts, {
						filetypes = { "css", "scss", "less", "html" },
						capabilities = caps,
					}))
				end,
				["emmet_ls"] = function()
					lsp_config.emmet_ls.setup({
						filetypes = { "twig", "templ", "htmldjango", "smarty", "markdown" },
					})
				end,
				["intelephense"] = function()
					lsp_config.intelephense.setup({
						settings = {
							-- intelephense = {
							-- 	diagnostics = { enable = true },
							-- 	telemetry = { enable = false },
							-- 	codeLens = {
							-- 		implementations = { enable = true },
							-- 	},
							-- },
						},
					})
				end,
				["lua_ls"] = function()
					lsp_config.lua_ls.setup(vim.tbl_deep_extend("force", handler_opts, {
						settings = {
							Lua = {
								completion = {
									callSnippet = "Replace",
								},
								telemetry = {
									enable = false,
								},
							},
						},
					}))
				end,
			}
			mason_lspconfig.setup_handlers(handlers)
		end,
		dependencies = {
			{
				"neovim/nvim-lspconfig",
				dependencies = {
					{
						"folke/neodev.nvim",
						config = function()
							require("neodev").setup({
								override = function(_, library)
									library.enable = true
									library.plugins = true
								end,
							})
						end,
					},
				},
			},
			{
				"nvim-lua/lsp-status.nvim",
				config = function()
					local lsp_status = require("lsp-status")
					lsp_status.register_progress()
				end,
			},
			{
				"williamboman/mason.nvim",
				config = function()
					local mason = require("mason")
					mason.setup({
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
					})
				end,
				opts = {
					ensure_installed = {},
				},
			},
		},
	},
}
