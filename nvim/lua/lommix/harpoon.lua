local ok, harpoon = pcall(require, "harpoon.ui")
if not ok then
	return
end

local mark = require("harpoon.mark")

vim.keymap.set("n", "<leader>hm", mark.add_file, { silent = true })
vim.keymap.set("n", "<leader>hh", harpoon.toggle_quick_menu, { silent = true })

