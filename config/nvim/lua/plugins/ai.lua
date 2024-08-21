return {
	-- chat gpt
	{
		"jackMort/ChatGPT.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		keys = {
			-- { "<leader>t", ":ChatGPT<CR>" },
		},
		event = "VeryLazy",
		config = function()
			require("chatgpt").setup()
		end,
	},
	-- Ollama
	{
		-- "lommix/ollamachad.nvim",
		dir = "~/Projects/nvim_plugins/ollamachad.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local Chat = require("ollamachad.chat")
			local gen = require("ollamachad.generate")
			local util = require("ollamachad.util")

			-- toggle response buffer again
			vim.keymap.set("n", "<leader>co", function()
				gen.toggle_popup()
			end, { silent = true })

			-- prompt visual selection
			-- vim.keymap.set("v", "<leader>cc", function()
			-- 	local instruction = "You are a helpful assistant. Provide a response to the following prompt: "
			-- 	local request = {
			-- 		model = "dolphin-llama3",
			-- 		prompt = instruction .. util.read_visiual_lines(),
			-- 	}
			-- 	gen.prompt(request)
			-- end, { silent = true })
			--
			-- -- rewrite text
			-- vim.keymap.set("v", "<leader>cr", function()
			-- 	local instruction =
			-- 		"Please rewrite the following text to improve clarity, coherence, and technical accuracy. Ensure that the revised version maintains the original meaning but is more polished and professional. The text may contain technical terms and concepts, but it's not exclusively technical. Here is the text that needs to be rewritten: "
			-- 	local request = {
			-- 		model = "dolphin-llama3",
			-- 		prompt = instruction .. util.read_visiual_lines(),
			-- 	}
			-- 	gen.prompt(request)
			-- end, { silent = true })

			-- toggle chat
			local chat = Chat:new({
				cache_file = "/home/lommix/.cache/nvim/ollamachad",
			})

			vim.keymap.set("n", "<leader>t", function()
				chat:toggle()
			end, { silent = true })
		end,
	},
}
