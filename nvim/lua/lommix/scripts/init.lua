local ollama = require("lommix.scripts.ollama")



vim.keymap.set("n", "<leader>cc", function()
	ollama.run_in_term(vim.fn.input("Prompt: "))
end, { silent = true })

vim.keymap.set("v", "<leader>cc", ollama.run_visual_as_prompt, { silent = true })
