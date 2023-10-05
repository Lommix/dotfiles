local plen = require("plenary.window.float")
local ollama = require("lommix.scripts.ollama")

vim.keymap.set("n", "<leader>ss", function()
	ollama.exec("Give short and precise answers.", vim.fn.input("Prompt: "), function(lines)
		local float = plen.centered()
		vim.api.nvim_buf_set_lines(float.bufnr, 0, -1, false, lines)
	end)
end, { silent = true })

vim.keymap.set("n", "<leader>cc", function()
	ollama.run_in_term(vim.fn.input("Prompt: "))
end, { silent = true })

vim.keymap.set("v", "<leader>cc", ollama.run_visual_as_prompt, { silent = true })
