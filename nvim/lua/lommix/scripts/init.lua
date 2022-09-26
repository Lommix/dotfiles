local shopware = require("lommix.scripts.shopware")
local cheatsheet = require("lommix.scripts.cheatsheet")
local quicky = require("lommix.scripts.quicky")

-- reload on run for debug stuff
local function debug()
    quicky = R("lommix.scripts.quicky")
    quicky.open()
end

-- shopware scripties binds
vim.keymap.set("n", "<leader>ss", shopware.service_finder, { silent = true })
vim.keymap.set("n", "<leader>cc", cheatsheet.search, { silent = true })
vim.keymap.set("n", "<leader>n", quicky.open, { silent = true })
