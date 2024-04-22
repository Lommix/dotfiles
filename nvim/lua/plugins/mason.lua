local servers = {
	"cssls",
	"cssmodules_ls",
	"emmet_ls",
	"html",
	"jdtls",
	"jsonls",
	"lua_ls",
	"tflint",
	"pyright",
	"yamlls",
	"bashls",
	"clangd",
	"typst_lsp",
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
					require("lsp-inlayhints").on_attach(client, bufnr)
					lsp_status.on_attach(client)
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
				--virtual_text = false,
				virtual_text = {
					prefix = icons.ui.Gear,
					severity = vim.diagnostic.severity.ERROR,
				},
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
				["tinymist"] = function()
					print("hello world")
					require("lspconfig").tinymist.setup({})
				end,
				["ltex"] = function()
					lsp_config.ltex.setup(vim.tbl_extend("force", handler_opts, {
						filetypes = { "text", "markdown", "md" },
						flags = { debounce_text_changes = 300 },
						cmd = { "ltex-ls" },
						settings = {
							ltex = {
								enabled = { "latex", "bib", "markdown", "tex" },
								-- language = "auto",
								-- language = "en-US",
								language = "de-DE",
								diagnosticSeverity = "INFO",
								setenceCacheSize = 4000,
								additionalRules = {
									enablePickyRules = true,
								},
								completionEnabled = true,
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
						filetypes = { "html", "twig", "htmldjango", "javascript" },
					}))
				end,
				["cssls"] = function()
					local capabilities = handler_opts.capabilities
					capabilities.textDocument.completion.completionItem.snippetSupport = true
					lsp_config.cssls.setup(vim.tbl_extend("force", handler_opts, {
						filetypes = { "css", "scss", "less", "javascript" },
						capabilities = capabilities,
					}))
				end,
				["emmet_ls"] = function()
					lsp_config.emmet_ls.setup({
						filetypes = { "twig", "html", "htmldjango", "smarty" },
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
							require("neodev").setup()
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
				"lvimuser/lsp-inlayhints.nvim",
				config = function()
					require("lsp-inlayhints").setup({
						inlay_hints = {
							parameter_hints = {
								show = false,
								-- prefix = "<- ",
								separator = ", ",
							},
							type_hints = {
								-- type and other hints
								show = true,
								prefix = "",
								separator = ", ",
								remove_colon_end = false,
								remove_colon_start = false,
							},
							-- separator between types and parameter hints. Note that type hints are
							-- shown before parameter
							labels_separator = "  ",
							-- whether to align to the length of the longest line in the file
							max_len_align = false,
							-- padding from the left if max_len_align is true
							max_len_align_padding = 1,
							-- whether to align to the extreme right or not
							right_align = false,
							-- padding from the right if right_align is true
							right_align_padding = 7,
							-- highlight group
							highlight = "Comment",
						},
						debug_mode = false,
					})
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
