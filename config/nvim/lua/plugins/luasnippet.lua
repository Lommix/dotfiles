return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	dependencies = { "rafamadriz/friendly-snippets" },
	config = function()
		local ls = require("luasnip")

		-- VSCode-style snippets (friendly-snippets)
		require("luasnip.loaders.from_vscode").lazy_load()

		-- VSCode-OSS extension snippets (if any exist)
		local vscode_ext_dir = vim.fn.expand("~/.vscode-oss/extensions")
		if vim.fn.isdirectory(vscode_ext_dir) == 1 then
			local paths = {}
			for _, dir in ipairs(vim.fn.glob(vscode_ext_dir .. "/*", true, true)) do
				if vim.fn.isdirectory(dir) == 1 then
					table.insert(paths, dir)
				end
			end
			if #paths > 0 then
				require("luasnip.loaders.from_vscode").load({ paths = paths })
			end
		end

		-- Custom Lua snippets (always loaded)
		require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/snippets/" } })

		ls.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
			enable_autosnippets = true,
		})

		--jump forward
		vim.keymap.set({ "i", "s" }, "<c-j>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			end
		end, { silent = true })

		-- choice
		vim.keymap.set({ "i", "s" }, "<c-l>", function()
			if ls.choice_active() then
				ls.change_choice()
			end
		end)
	end,
}
