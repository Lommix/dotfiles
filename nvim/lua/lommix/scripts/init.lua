local plen = require("plenary.window.float")
local ollama = require("lommix.scripts.ollama")

local win_options = {
	winblend = 10,
	border = "rounded",
}

vim.keymap.set("n", "<leader>cc", function()
	ollama.exec("", vim.fn.input("Prompt: "), function(lines)
		local float = plen.percentage_range_window(0.8, 0.8, win_options)
		vim.api.nvim_buf_set_lines(float.bufnr, 0, -1, false, lines)
	end)
end, { silent = true })

vim.keymap.set("v", "<leader>cc", function()
	ollama.run_visual_as_prompt("Rewrite and Improve the following text:", function(lines)
		local float = plen.percentage_range_window(0.8, 0.8, win_options)
		vim.api.nvim_buf_set_lines(float.bufnr, 0, -1, false, lines)
	end)
end, { silent = true })
