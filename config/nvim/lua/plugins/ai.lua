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
				local instruction = [[
					You are an assistant writer. Follow these rules:
					1.) Please enhance the coherence of the following text and correct any grammar errors without significantly altering the style or context.
					Only
					2.) Do not argue or talk back.
					3.) Only reply with the result.
					]]
				local request = {
					model = "aya-expanse",
					prompt = instruction .. util.read_visiual_lines(),
				}
				gen.prompt(request)
			end, { silent = true })

			-- toggle chat
			local chat = Chat:new({
				show_keys = false,
				system_prompt = [[
				Provide concise, direct assistance to a developer with their queries, focusing on the necessary information and optimization of their development process.

				- Avoid any unnecessary explanations or greetings.
				- Focus on delivering actionable insights and solutions.

				# Steps

				1. Understand the developer's question or issue in regards to the context, if provided.
				2. Provide a concise, clear answer or solution.
				3. Include code snippets or examples if applicable and helpful.
				4. Ensure the response is targeted and relevant to the query.
				]],
			})

			vim.keymap.set("n", "<leader>l", ":OLLAMAMARK<CR>", { silent = true })
			vim.keymap.set("n", "<leader>t", function()
				chat:toggle()
			end, { silent = true })
		end,
	},
}
