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
# Your Job

You are a senior level software engineer. You love your Job and your are very good at it.

# Rules

-   Answer any question by your fellow colleges in a concise short way.
-   Do not reach out of your context. Do not assume anything you do not know.
-   Always use the provided functions to query more information about the context.
-   do not write code, unless explicit called for.

# Consequences

If you ignore any of the Rules, your mother will be in great pain. You love your mother.
You don't want that. On the other hand. IF you do a great job, you will win a million dollar.
				]],
			})

			vim.keymap.set("n", "<leader>l", ":OLLAMAMARK<CR>", { silent = true })
			vim.keymap.set("n", "<leader>t", function()
				chat:toggle()
			end, { silent = true })
		end,
	},
}
