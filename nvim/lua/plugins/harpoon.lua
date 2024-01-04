return {
	"ThePrimeagen/harpoon",
	config=function()

		local harpoon = require("harpoon.ui")
		local mark = require("harpoon.mark")

		vim.keymap.set("n", "<leader>hm", mark.add_file, { silent = true })
		vim.keymap.set("n", "<leader>hh", harpoon.toggle_quick_menu, { silent = true })
	end
}
