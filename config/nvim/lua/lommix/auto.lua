-- auto commands here
local group = vim.api.nvim_create_augroup("autocmd", { clear = true })

-- auto center cursor
vim.api.nvim_create_autocmd("CursorMoved", {
	command = "normal! zz",
	group = group,
})

-- auto trim whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*" },
	command = [[%s/\s\+$//e]],
	group = group,
})

-- auto format xml
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*.xml", "*.xsd" },
	callback = function()
		vim.lsp.buf.format()
	end,
	group = group,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "*.typ" },
	command = "setfiletype typst <CR> lua  require'lspconfig'.tinymist.setup{}",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.typ" },
	command = "set filetype=typst",
})

-- save current oil dir in a global var
vim.api.nvim_create_autocmd(
	{ "DirChanged", "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" },
	{
		callback = function()
			local ok, oil = pcall(require, "oil")
			if not ok then
				return
			end

			vim.g.oil_dir = oil.get_current_dir()
		end,
	}
)
