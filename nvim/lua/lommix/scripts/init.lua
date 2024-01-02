local plenary = require("plenary.window.float")
local ollama = require("lommix.scripts.ollama")
local Chat = require("lommix.scripts.chat")

local win_options = {
	winblend = 10,
	border = "rounded",
	out_bufnr = vim.api.nvim_create_buf(false, true),
}

local chat = Chat:new("mistral")

vim.api.nvim_buf_set_option(win_options.out_bufnr, "filetype", "markdown")

-- open buffer
vim.keymap.set("n", "<leader>o", function()
	chat:toggle()
end, { silent = true })

-- prompt visual selection
vim.keymap.set("v", "<leader>cc", function()
	local prompt = ollama.get_visual_lines(0)
	vim.api.nvim_buf_set_lines(win_options.out_bufnr, 0, -1, false, {}) -- Clear the buffer

	local float = plenary.percentage_range_window(0.8, 0.8, win_options)
	local win_width = vim.api.nvim_win_get_width(float.win_id) - 5

	local request = {
		model = "mistral",
		prompt = prompt,
	}

	ollama.prompt(request, float.bufnr, win_width)
end, { silent = true })

-- rewrite text
vim.keymap.set("v", "<leader>cr", function()
	local prompt = ollama.get_visual_lines(0)
	local context =
		"Please rewrite the following text to improve clarity, coherence, and technical accuracy. Ensure that the revised version maintains the original meaning but is more polished and professional. The text may contain technical terms and concepts, but it's not exclusively technical. Here is the text that needs to be rewritten: "
	vim.api.nvim_buf_set_lines(win_options.out_bufnr, 0, -1, false, {}) -- Clear the buffer

	local float = plenary.percentage_range_window(0.8, 0.8, win_options)
	local win_width = vim.api.nvim_win_get_width(float.win_id) - 5

	local request = {
		model = "mistral",
		prompt = context .. prompt,
	}

	ollama.prompt(request, float.bufnr, win_width)
end, { silent = true })
