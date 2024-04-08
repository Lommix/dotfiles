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

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "*.typ" },
	command = "setfiletype typst <CR> lua  require'lspconfig'.tinymist.setup{}",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.typ" },
	command = "set filetype=typst",
})
