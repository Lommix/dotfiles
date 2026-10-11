return {
	"stevearc/oil.nvim",
	lazy = false,
	config = function()
		local oil = require("oil")
		oil.setup({
			view_options = {
				is_hidden_file = function(name, bufnr)
					local is_dotfile = vim.startswith(name, ".")
					local is_bk = vim.startswith(name, "~")
					return is_dotfile or is_bk
				end,
			},
			keymaps = {
				["<CR>"] = {
					callback = function()
						if not require("lommix.oil_image").open() then
							require("oil.actions").select.callback()
						end
					end,
					desc = "open file or preview image",
				},
				["p"] = {
					callback = function()
						require("lommix.oil_image").toggle()
					end,
					desc = "toggle image preview",
				},
			},
		})
	end,
}
