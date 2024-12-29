-- auto commands here
local group = vim.api.nvim_create_augroup("autocmd", { clear = true })

-- auto spell check
vim.api.nvim_create_autocmd("BufRead", {
	pattern = { "*.md", "*.txt" },
	command = "setlocal spell",
	group = group,
})

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

-- fix scss
vim.api.nvim_create_autocmd("FileType", {
	pattern = "scss",
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 4
	end,
})

-- fix twig auto commenting
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.twig",
	callback = function()
		local ft = require("Comment.ft")
		ft.set("html", "{#%s#}")
	end,
})

-- fix twig auto commenting
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.html",
	callback = function()
		local ft = require("Comment.ft")
		ft.set("html", "<!-- %s -->")
	end,
})

-- fix twig auto commenting
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = { "*.aseprite" },
	callback = function()
		vim.fn.system("aseprite " .. vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) .. " &")
		vim.cmd("bdelete")
	end,
	group = group,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = { "*.png", "*.jpg", "*.jpeg" },
	callback = function()
		vim.fn.system("feh --scale-down" .. vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) .. " &")
		vim.cmd("bdelete")
	end,
	group = group,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = group,
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

-- auto format xml
-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
-- 	pattern = { "*.xml", "*.xsd" },
-- 	callback = function()
-- 		vim.lsp.buf.format()
-- 	end,
-- 	group = group,
-- })
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
