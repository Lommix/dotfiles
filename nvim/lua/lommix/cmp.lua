local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
	return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

local buffer_fts = {
	"markdown",
	"toml",
	"yaml",
	"json",
}

local function contains(t, value)
	for _, v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

local kind_icons = {
	Text = "",
	Method = "m",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

local compare = require("cmp.config.compare")

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local icons = require("lommix.icons")
local kind_icons = icons.kind

vim.g.cmp_active = true

cmp.setup({
	enabled = function()
		if
			require("cmp.config.context").in_treesitter_capture("comment") == true
			or require("cmp.config.context").in_syntax_group("Comment")
			or vim.api.nvim_buf_get_option(0, "buftype") == "prompt"
		then
			return false
		else
			return true
		end
	end,
	matching = {
		disallow_fuzzy_matching = true,
		disallow_fullfuzzy_matching = true,
		disallow_partial_fuzzy_matching = true,
		disallow_partial_matching = true,
		disallow_prefix_unmatching = false,
	},
	preselect = cmp.PreselectMode.None,
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
		["<C-q>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = false,
		}),
		["<TAB>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			-- elseif require("luasnip").jumpable() then
			-- 	vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif require("luasnip").jumpable(-1) then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
	}),
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			-- Kind icons
			vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
			vim_item.menu = ({
				nvim_lsp = "[LSP]",
				luasnip = "[Snippet]",
				buffer = "[Buffer]",
				path = "[Path]",
			})[entry.source.name]
			return vim_item
		end,
	},
	sources = {
		--	{ name = "crates", group_index = 1 },
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		-- {
		-- 	name = "buffer",
		-- 	group_index = 2,
		-- 	filter = function(entry, ctx)
		-- 		if not contains(buffer_fts, ctx.prev_context.filetype) then
		-- 			return true
		-- 		end
		-- 	end,
		-- },
		{ name = "path", group_index = 2 },
	},
	-- sorting = {
	-- 	priority_weight = 2,
	-- 	comparators = {
	-- 		compare.offset,
	-- 		compare.exact,
	-- 		compare.score,
	-- 		compare.recently_used,
	-- 		compare.locality,
	-- 		compare.sort_text,
	-- 		compare.length,
	-- 		compare.order,
	-- 	},
	-- },
	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},
	window = {
		documentation = {
			border = "rounded",
			winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
		},
		completion = {
			border = "rounded",
			winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
		},
	},
	experimental = {
		ghost_text = true,
	},
})
