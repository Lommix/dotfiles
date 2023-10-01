local cheatsheet = require("lommix.scripts.cheatsheet")

vim.keymap.set("n", "<leader>cc", cheatsheet.search, { silent = true })
