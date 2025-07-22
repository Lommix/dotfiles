return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets", { "L3MON4D3/LuaSnip", version = "v2.*" } },
	version = "1.3.*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			-- preset = "none",
			-- ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			-- ["<C-e>"] = { "hide" },
			-- ["<C-y>"] = { "select_and_accept" },
			-- ["<C-p>"] = { "select_prev", "fallback" },
			-- ["<C-n>"] = { "select_next", "fallback" },
			-- ["<C-b>"] = { "scroll_documentation_up", "fallback" },
			-- ["<C-f>"] = { "scroll_documentation_down", "fallback" },
			-- ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
		},
		-- signature = { enabled = true },
		snippets = { preset = "luasnip" },
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				sql = { "snippets", "dadbod", "buffer" },
			},
			-- add vim-dadbod-completion to your completion providers
			providers = {
				dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
				path = {
					opts = {
						get_cwd = function(_)
							return vim.fn.getcwd()
						end,
					},
				},
			},
		},
		completion = {
			documentation = {
				auto_show_delay_ms = 500,
			},
			menu = {
				auto_show = true,
				auto_show_delay_ms = 500,
			},
			accept = { auto_brackets = { enabled = false } },
			ghost_text = {
				enabled = false,
			},
		},
	},
	opts_extend = { "sources.default" },
}
