local ok, Popup = pcall(require, "nui.popup")
if not ok then
	return
end

local M = {}

local defaults = {
	path = "~/.quicky",
	popup_config = {
		size = {
			width = "90%",
			height = "90%",
		},
		position = "50%",
		enter = true,
		focusable = true,
		relative = "editor",
		border = {
			style = "rounded",
			text = {
				top = "Project Notes",
				top_align = "center",
			},
		},
		buf_options = {
			modifiable = true,
			readonly = false,
			swapfile = false,
			filetype = "markdown",
		},
		win_options = {
			winblend = 10,
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	},
}

local function open(title, path)
	local abs = vim.fn.expand(path)
	local popup = Popup(vim.tbl_deep_extend("force", defaults.popup_config, {
		border = { text = { top = title } },
	}))
	popup:show()

	local lines = vim.fn.filereadable(abs) == 1 and vim.fn.readfile(abs) or {}
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
	vim.wo[popup.winid].number = true

	popup:map("n", "q", function()
		vim.fn.writefile(vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false), abs)
		popup:hide()
		popup:unmount()
	end)
end

M.open_notes = function()
	open("Project Notes", defaults.path .. "/" .. string.gsub(vim.fn.getcwd(), "/", "") .. ".md")
end

M.open_global_notes = function()
	open("Global Notes", defaults.path .. "/global_note.md")
end

vim.keymap.set("n", "<leader>j", M.open_global_notes, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>n", M.open_notes, { noremap = true, silent = true })
return M
