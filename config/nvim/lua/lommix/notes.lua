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

M.open_notes = function()
	local path = defaults.path .. "/" .. string.gsub(vim.fn.getcwd(), "/", "") .. ".md"

	local popup = Popup(defaults.popup_config)
	popup:show()

	vim.api.nvim_buf_call(popup.bufnr, function()
		vim.cmd("e " .. path)
		vim.cmd("set number")
	end)

	popup:map("n", "q", function()
		vim.cmd("w")
		popup:hide()
		popup:unmount()
	end)
end

M.open_global_notes = function()
	local path = defaults.path .. "/" .. "global_note.md"
	local opts = defaults.popup_config
	opts.border.text.top = "Global Notes"

	local popup = Popup(opts)
	popup:show()

	vim.api.nvim_buf_call(popup.bufnr, function()
		vim.cmd("e " .. path)
		vim.cmd("set number")
	end)

	popup:map("n", "q", function()
		vim.cmd("w")
		popup:hide()
		popup:unmount()
	end)
end

vim.keymap.set("n", "<leader>j", M.open_global_notes, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>n", M.open_notes, { noremap = true, silent = true })
return M
