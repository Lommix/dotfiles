local ok, Popup = pcall(require, "nui.popup")
if not ok then
	return
end

local M = {}

local defaults = {
	path = "~/.quicky",
	popup_config = {
		size = {
			width = "80%",
			height = "80%",
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

local popup = Popup(defaults.popup_config)

M.open_notes = function()
	local path = defaults.path .. "/" .. string.gsub(vim.fn.getcwd(), "/", "") .. ".md"
	popup:show()

	vim.api.nvim_buf_call(popup.bufnr, function()
		vim.cmd("e " .. path)
		vim.cmd("set number")
	end)

	popup:map("n", "q", function()
		vim.cmd("w")
		popup:hide()
	end)
end

vim.keymap.set("n", "<leader>n", M.open_notes, { noremap = true, silent = true })
return M
