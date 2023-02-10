local ok, ls = pcall(require, "luasnip")
if not ok then
	return
end

-- any vscode like plugin
require("luasnip.loaders.from_vscode").lazy_load()

-- custom plugins
if vim.fn.isdirectory("~/.snippets/solid") then
	require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.snippets/solid/" } })
end

-- lua snippets
require("luasnip.loaders.from_lua").load({ paths = {"~/.config/nvim/snippets/"} })

local types = require("luasnip.util.types")

ls.config.set_config({
	history = true,
	updateevents = "TextChanged,TextChangedI",
	enable_autosnippets = true,
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "<", "Error" } },
			},
		},
	},
})

--jump forward
vim.keymap.set({ "i", "s" }, "<C-j>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = true })

--jump back
vim.keymap.set({ "i", "s" }, "<C-k>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, { silent = true })

-- choice
vim.keymap.set({ "i", "s" }, "<C-l>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)
