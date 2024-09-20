return {
	-- Ollama
	{
		-- "lommix/ollamachad.nvim",
		dir = "~/Projects/nvim_plugins/ollamachad.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("ollamachad.init").setup()

			local Chat = require("ollamachad.chat")
			local gen = require("ollamachad.generate")
			local util = require("ollamachad.util")

			-- toggle response buffer again
			vim.keymap.set("n", "<leader>co", function()
				gen.toggle_popup()
			end, { silent = true })

			-- -- rewrite text
			vim.keymap.set("v", "<leader>cr", function()
				local instruction =
					"Please rewrite the following text to improve clarity, coherence while keeping the vibe:"
				local request = {
					model = "llama3.1:latest",
					prompt = instruction .. util.read_visiual_lines(),
				}
				gen.prompt(request)
			end, { silent = true })

			-- toggle chat
			local chat = Chat:new({
				show_keys = false,
				cache_file = "/home/lommix/.cache/nvim/ollamachad",
				system_prompt = [[
1. Only generate code if I make a request or if you ask me and I say yes **only generate code after you follow rule number 2.
2. Before generating code, check the context:
    - are you missing context?
    - is the instruction unclear?
3. When programming follow Rule 1 , then Rule 2 in that order
				]],
			})

			vim.keymap.set("n", "<leader>l", ":OLLAMAMARK<CR>", { silent = true })
			vim.keymap.set("n", "<leader>t", function()
				chat:toggle()
			end, { silent = true })

			-- vim.keymap.set("n", "<leader>l", function()
			-- 	local file_path = vim.api.nvim_buf_get_name(0)
			--
			-- 	local function contains(table, value)
			-- 		for _, v in ipairs(table) do
			-- 			if v == value then
			-- 				return true
			-- 			end
			-- 		end
			-- 		return false
			-- 	end
			--
			-- 	if vim.fn.filereadable(file_path) == 1 then
			-- 		if not contains(chat.context_files, file_path) then
			-- 			print("Context marked!")
			-- 			table.insert(chat.context_files, file_path)
			-- 		end
			-- 	else
			-- 		print("Not a file!")
			-- 	end
			-- end, { silent = true })
		end,
	},
}
