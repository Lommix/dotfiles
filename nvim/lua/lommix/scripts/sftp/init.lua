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

local opts = {
	save_dir = "~/.quicky/sftp",
	key_path = "~/.ssh/id_ed25519",
	command = "rsync",
}

local current_file = nil

local sftpfilepath = opts.save_dir .. "/" .. string.gsub(vim.fn.getcwd(), "/", "") .. "-SFTP"
local a = vim.api
local Job = require("plenary.job")
local buffer = a.nvim_create_buf(true, true)

local wincfg = {
	height = 5,
	title = "SFTP-UPLOAD :: Connections",
	width = 50,
	border = "double",
	relative = "editor",
	col = 30,
	row = 5,
}

vim.g.lommix_sftp_upload = function()
	local config = a.nvim_get_current_line()
	local server_path = config .. "/" .. current_file
	local local_path = vim.fn.getcwd() .. "/" .. current_file

	local cmd = "rsync --stats --progress -e 'ssh -i "
		.. opts.key_path
		.. "' "
		.. local_path
		.. " "
		.. server_path

	vim.cmd(':let @+="' .. cmd .. '"')
	vim.cmd(":q!")

end

vim.keymap.set("n", "<leader>up", function()
	if not vim.fn.filereadable(sftpfilepath) == true then
		do
			return
		end
	end
	current_file = vim.fn.expand("%")
	local win = a.nvim_open_win(buffer, true, wincfg)
	a.nvim_buf_call(buffer, function()
		vim.cmd("e " .. sftpfilepath)
	end)
	a.nvim_buf_set_keymap(buffer, "n", "q", ":wq<CR>", { silent = true })
	a.nvim_buf_set_keymap(buffer, "n", "<CR>", ":lua vim.g.lommix_sftp_upload()<CR>", { silent = true })
end, { silent = true })
