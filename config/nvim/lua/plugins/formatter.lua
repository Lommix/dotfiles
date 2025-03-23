return {
	"mhartington/formatter.nvim",
	config = function()
		local util = require("formatter.util")
		local formatter = require("formatter")

		function AutoIndentBuffer()
			local row, col = unpack(vim.api.nvim_win_get_cursor(0))
			vim.cmd("normal! gg=G")
			vim.api.nvim_win_set_cursor(0, { row, col })
			vim.cmd("normal! zz")
		end

		formatter.setup({
			logging = true,
			log_level = vim.log.levels.WARN,
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
					function()
						return {
							exe = "stylua",
							args = {
								"--search-parent-directories",
								"--stdin-filepath",
								util.escape_path(util.get_current_buffer_file_path()),
								"--",
								"-",
							},
							stdin = true,
						}
					end,
				},
				ron = {
					function()
						return {
							exe = "ronfmt",
							args = {},
						}
					end,
				},
				templ = {
					require("formatter.filetypes.templ").templfmt(),
				},
				toml = {
					require("formatter.filetypes.toml").taplo(),
				},
				php = {
					function()
						vim.lsp.buf.format({})
						return nil
					end,
				},
				markdown = {
					require("formatter.filetypes.markdown").prettier,
				},
				json = {
					require("formatter.filetypes.json").jq,
				},
				python = {
					require("formatter.filetypes.python").black,
				},
				javascript = {
					require("formatter.filetypes.javascript").prettier,
				},
				typescript = {
					require("formatter.filetypes.typescript").prettier,
				},
				zig = {
					require("formatter.filetypes.zig").zigfmt,
				},
				odin = {
					function()
						return {
							exe = "odinfmt",
							args = { "-w" },
						}
					end,
				},
				typst = {
					function()
						return {
							exe = "typstfmt",
							args = { "--config-path", "~/typstfmt.toml" },
						}
					end,
				},
				less = {
					require("formatter.filetypes.css").prettier,
				},
				scss = {
					function()
						AutoIndentBuffer()
						return nil
					end,
				},
				css = {
					require("formatter.filetypes.css").prettier,
				},
				sql = {
					require("formatter.filetypes.sql").sqlfluff,
				},
				twig = {
					require("formatter.filetypes.twig").djlint,
				},
				smarty = {
					require("formatter.filetypes.html").prettier,
				},
				html = {
					require("formatter.filetypes.html").prettier,
				},
				htmljango = {
					require("formatter.filetypes.html").prettier,
				},
				rust = {
					require("formatter.filetypes.rust").rustfmt,
				},
				go = {
					require("formatter.filetypes.go").gofumpt,
				},
				xml = {
					function()
						vim.lsp.buf.format({})
						return nil
					end,
				},
			},
		})
	end,
}
