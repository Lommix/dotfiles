return {
	{
		"Exafunction/codeium.vim",
		config = function()

			vim.g.codeium_enabled = false

			vim.keymap.set("i", "<C-g>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true, silent = true })
			vim.keymap.set("i", "<c-;>", function()
				return vim.fn["codeium#CycleCompletions"](1)
			end, { expr = true, silent = true })
			vim.keymap.set("i", "<c-,>", function()
				return vim.fn["codeium#CycleCompletions"](-1)
			end, { expr = true, silent = true })
			vim.keymap.set("i", "<c-x>", function()
				return vim.fn["codeium#Clear"]()
			end, { expr = true, silent = true })
		end,
	},
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
