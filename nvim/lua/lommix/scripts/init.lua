local plen = require("plenary.window.float")
local ollama = require("lommix.scripts.ollama")

local win_options = {
	winblend = 10,
	border = "rounded",
	bufnr = vim.api.nvim_create_buf(false, true)
}

------------------------------------------------------------------
-- general purpose questions
vim.keymap.set("n", "<leader>cc", function()
	plen.clear(win_options.bufnr)
	local float = plen.percentage_range_window(0.8, 0.8, win_options)
	ollama.run("mistral:instruct", "", vim.fn.input("Prompt: "), float.bufnr)
end, { silent = true })

vim.keymap.set("v", "<leader>cc", function()
	local prompt = ollama.get_visual_lines(0)
	plen.clear(win_options.bufnr)
	local float = plen.percentage_range_window(0.8, 0.8, win_options)
	ollama.run("mistral:instruct", "", prompt, float.bufnr)
end, { silent = true })

------------------------------------------------------------------
-- general purpose math & logic questions
vim.keymap.set("n", "<leader>cm", function()
	plen.clear(win_options.bufnr)
	local float = plen.percentage_range_window(0.8, 0.8, win_options)
	ollama.run("wizard-math", "", vim.fn.input("Prompt: "), float.bufnr)
end, { silent = true })

vim.keymap.set("v", "<leader>cm", function()
	local prompt = ollama.get_visual_lines(0)
	plen.clear(win_options.bufnr)
	local float = plen.percentage_range_window(0.8, 0.8, win_options)
	ollama.run("wizard-math", "", prompt, float.bufnr)
end, { silent = true })

------------------------------------------------------------------
-- rewrite text lul
vim.keymap.set("v", "<leader>cr", function()
	local prompt = ollama.get_visual_lines(0)
	local context = "Please rewrite these sentances:"
	plen.clear(win_options.bufnr)
	local float = plen.percentage_range_window(0.8, 0.8, win_options)
	ollama.run("mistral:instruct", context, prompt, float.bufnr)
end, { silent = true })
