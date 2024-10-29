return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		vim.keymap.set("n", "<leader>hm", function()
			harpoon:list():add()
		end, { silent = true })

		vim.keymap.set("n", "<leader>hh", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { silent = true })

		vim.keymap.set("n", "<C-z>", function()
			harpoon:list():select(1)
		end)
		vim.keymap.set("n", "<C-h>", function()
			harpoon:list():select(2)
		end)
		vim.keymap.set("n", "<C-b>", function()
			harpoon:list():select(3)
		end)
	end,
}
