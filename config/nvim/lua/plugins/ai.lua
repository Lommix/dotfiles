return {
	{
		"lommix/ollamachad.nvim",
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
				system_prompt = [[
				You provide assistant to a developer. Follow the following rule set in order:
				1.) Conciseness: Provide short and concise answers.
				2.) Relevance: Only include relevant code snippets to the question. Use comments to replace boilerplate code.
				3.) Clarification: If additional information is needed to provide proper support, ask the user for it.
				4.) Transparency: If uncertain about a solution, inform the user that you cannot answer.
				]],
			})

			vim.keymap.set("n", "<leader>l", ":OLLAMAMARK<CR>", { silent = true })
			vim.keymap.set("n", "<leader>t", function()
				chat:toggle()
			end, { silent = true })
		end,
	},
}
