local function enable(lang)
	local lsp_config = require("lspconfig")
	local lsp_status = require("lsp-status")

	local handler_opts = {
		capabilities = lsp_status.capabilities,
		on_attach = function(client, bufnr)
			require("lsp-inlayhints").on_attach(client, bufnr)
			lsp_status.on_attach(client)
		end,
	}

	lsp_config.ltex.setup(vim.tbl_extend("force", handler_opts, {
		filetypes = { "text", "markdown", "md" },
		flags = { debounce_text_changes = 300 },
		cmd = { "ltex-ls" },
		settings = {
			ltex = {
				enabled = { "latex", "bib", "markdown", "tex" },
				-- language = "auto",
				-- language = "en-US",
				language = lang,
				diagnosticSeverity = "INFO",
				setenceCacheSize = 4000,
				additionalRules = {
					enablePickyRules = true,
				},
				completionEnabled = true,
			},
		},
	}))
end

local function enable_en()
	enable("en-US")
end

local function enable_de()
	enable("de-DE")
end

vim.api.nvim_create_user_command("EN", enable_en, {})
vim.api.nvim_create_user_command("DE", enable_de, {})
