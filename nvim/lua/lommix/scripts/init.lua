local ok, shopware = pcall(require, "lommix.scripts.shopware")
if not ok then
	return
end

-- reload on run for debug stuff
local function debug()
	package.loaded["lommix.scripts.shopware"] = nil
	shopware = require("lommix.scripts.shopware")
	shopware.service_finder()
end

-- shopware scripties binds
vim.keymap.set("n", "<leader>ss", shopware.service_finder, { silent = true })
