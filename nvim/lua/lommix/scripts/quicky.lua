local M = {}
local a = vim.api
local Job = require("plenary.job")
local buffer = a.nvim_create_buf(false, true)
local editorWidth = a.nvim_get_option("columns")
local editorHeight = a.nvim_get_option("lines")

local wincfg = {
	height = editorHeight - 20,
	width = editorWidth - 20,
	border = "double",
	relative = "editor",
	col = 10,
	row = 10,
}

local config = {
	cache_dir = "~/.quicky",
}

local project_cache_path = config.cache_dir .. "/" .. string.gsub(vim.fn.getcwd(), "/", "") .. ".txt"

M.open = function()
	if vim.fn.filereadable(project_cache_path) == true then
	end

	local win = a.nvim_open_win(buffer, true, wincfg)
	--	a.nvim_buf_call(buffer, function() end)
	a.nvim_buf_set_keymap(buffer, "n", "q", ":q<CR>", { silent = true })
end
return M
