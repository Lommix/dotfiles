local plen = require("plenary.window.float")
local ollama = require("lommix.scripts.ollama")

local win_options = {
	winblend = 10,
	border = "rounded",
}

--- @return string
local function get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line, start_col = start_pos[2] - 1, start_pos[3]
	local end_line, end_col = end_pos[2] - 1, end_pos[3]

	local t = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
	return table.concat(t, "\n")
end

vim.keymap.set("n", "<leader>cc", function()
	local float = plen.percentage_range_window(0.8, 0.8, win_options)
	ollama.exec_to_buffer("", vim.fn.input("Prompt: "), float.bufnr)
end, { silent = true })

vim.keymap.set("v", "<leader>cc", function()
	local prompt = get_visual_selection()
	local float = plen.percentage_range_window(0.8, 0.8, win_options)
	ollama.exec_to_buffer("", prompt, float.bufnr)
end, { silent = true })

-- vim.keymap.set("v", "<leader>cc", function()
-- 	local float = plen.percentage_range_window(0.8, 0.8, win_options)
-- 	ollama.run_visual_as_prompt("Rewrite and Improve the following text:", function(lines)
-- 		local float = plen.percentage_range_window(0.8, 0.8, win_options)
-- 		vim.api.nvim_buf_set_lines(float.bufnr, 0, -1, false, lines)
-- 	end)
-- end, { silent = true })
