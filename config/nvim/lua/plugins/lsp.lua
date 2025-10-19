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
			local mason = require("mason")
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
				virtual_lines = false,
				virtual_text = true,
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

			-- lsp_config.rust_analyzer.setup(vim.tbl_extend("force", handler_opts, {
			-- 	settings = {
			-- 		["rust-analyzer"] = {
			-- 			diagnostics = {
			-- 				enable = false,
			-- 			},
			-- 		},
			-- 	},
			-- }))

			-- lsp_config.lemminx.setup(vim.tbl_extend("force", handler_opts, {
			-- 	filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
			-- 	single_file_support = true,
			-- 	settings = {
			-- 		xml = {
			-- 			trace = {
			-- 				server = "verbose",
			-- 			},
			-- 			logs = {
			-- 				client = true,
			-- 			},
			-- 			format = {
			-- 				splitAttributes = "alignWithFirstAttr",
			-- 				joinContentLines = true,
			-- 				preservedNewlines = 1,
			-- 				insertSpaces = true,
			-- 				tabSize = 4,
			-- 			},
			-- 		},
			-- 	},
			-- }))

			vim.lsp.config("wgsl_analyzer", {
				filetypes = { "wgsl" },
			})
			vim.lsp.enable("wgsl_analyzer")

			vim.lsp.config("html", {
				filetypes = { "html", "twig", "templ" },
			})
			vim.lsp.enable("html")

			-- lsp_config.html.setup(vim.tbl_extend("force", handler_opts, {
			-- 	filetypes = { "html", "twig", "templ" },
			-- }))

			local caps = handler_opts.capabilities
			caps.textDocument.completion.completionItem.snippetSupport = true

			vim.lsp.config("cssls", {
				filetypes = { "css", "scss", "less", "html" },
				capabilities = caps,
			})
			vim.lsp.enable("cssls")

			-- lsp_config.cssls.setup(vim.tbl_extend("force", handler_opts, {
			-- 	filetypes = { "css", "scss", "less", "html" },
			-- 	capabilities = caps,
			-- }))

			vim.lsp.config("emmet_ls", {
				filetypes = { "twig", "html", "templ", "htmldjango", "smarty", "markdown" },
			})
			vim.lsp.enable("emmet_ls")

			-- lsp_config.emmet_ls.setup({
			-- 	filetypes = { "twig", "templ", "htmldjango", "smarty", "markdown" },
			-- })

			local get_intelephense_license = function()
				local path = os.getenv("HOME") .. "/intelephense/licence.txt"
				local f = assert(io.open(path, "rb"))
				local content = f:read("*a")
				f:close()
				return string.gsub(content, "%s+", "")
			end

			local key = get_intelephense_license()

			vim.lsp.config("intelephense", {
				settings = {
					licenceKey = key,
					-- intelephense = {
					diagnostics = { enable = true },
					telemetry = { enable = false },
					codeLens = {
						implementations = { enable = true },
					},
					-- },
				},
				init_options = {
					licenceKey = key,
					intelephense = {
						diagnostics = { enable = true },
						telemetry = { enable = false },
						codeLens = {
							implementations = { enable = true },
						},
					},
				},
			})
			vim.lsp.enable("intelephense")

			vim.lsp.config("lua_ls", {
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
			})
			vim.lsp.enable("lua_ls")

			vim.lsp.config("zls", {
				-- cmd = { "/hole/lommix/.local/bin/zls" },
				settings = {
					zls = {
						-- force_autofix = true,
						include_at_in_builtins = true,
					},
					-- force_autofix = true,
					-- enable_build_on_save = true,
					-- highlight_global_var_declarations = true,
					-- dangerous_comptime_experiments_do_not_enable = true,
					-- inlay_hints_hide_redundant_param_names_last_token = true,
				},
			})
			vim.lsp.enable("zls")

			vim.lsp.config("gdscript", {})
			vim.lsp.enable("gdscript")
			vim.lsp.config("ts_ls", {})
			vim.lsp.enable("ts_ls")

			mason.setup({})
			mason_lspconfig.setup({})

			vim.lsp.inlay_hint.enable(false)

			-- vim.lsp.setup_handlers(handlers)
			-- mason_lspconfig.setup_handlers(handlers)
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
				config = function() end,
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
			},
		},
	},
}
