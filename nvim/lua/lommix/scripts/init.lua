local cheatsheet = require("lommix.scripts.cheatsheet")
local quicky = require("lommix.scripts.quicky")

vim.keymap.set("n", "<leader>cc", cheatsheet.search, { silent = true })
vim.keymap.set("n", "<leader>n", quicky.open, { silent = true })
