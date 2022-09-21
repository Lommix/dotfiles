local shopware = require("lommix.scripts.shopware")
local cheatsheet = require("lommix.scripts.cheatsheet")

-- reload on run for debug stuff
local function debug()
	package.loaded["lommix.scripts.cheatsheet"] = nil
	cheatsheet = require("lommix.scripts.cheatsheet")
    cheatsheet.search()
end

-- shopware scripties binds
vim.keymap.set("n", "<leader>ss",shopware.service_finder, { silent = true })
vim.keymap.set("n", "<leader>cc",debug, { silent = true })
