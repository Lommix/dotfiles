vim.o.completeopt = "menuone,noinsert,popup"
vim.o.pumheight = 12
vim.o.pumblend = 0
vim.o.pumborder = "rounded"
vim.o.winborder = "rounded"

vim.lsp.protocol.CompletionItemKind = {
	" Text",          -- 1:  plain text
	" Method",        -- 2:  class method
	"󰊕 Function",     -- 3:  function
	" Constructor",   -- 4:  constructor
	" Field",         -- 5:  struct/class field
	"󰀫 Variable",     -- 6:  variable
	" Class",         -- 7:  class
	" Interface",     -- 8:  interface
	" Module",        -- 9:  module/namespace
	" Property",      -- 10: property
	" Unit",          -- 11: unit of measure
	"󰎠 Value",        -- 12: value literal
	" Enum",          -- 13: enum type
	" Keyword",       -- 14: language keyword
	" Snippet",       -- 15: snippet
	" Color",         -- 16: color
	" File",          -- 17: file
	" Reference",     -- 18: reference
	" Folder",        -- 19: folder/directory
	" EnumMember",    -- 20: enum variant
	"󰏿 Constant",     -- 21: constant
	" Struct",        -- 22: struct
	" Event",         -- 23: event
	" Operator",      -- 24: operator
	" TypeParam",     -- 25: type parameter/generic
}

local kind_hl_map = {
	[1]  = "String",        -- Text
	[2]  = "Function",      -- Method
	[3]  = "Function",      -- Function
	[4]  = "TSConstructor",  -- Constructor
	[5]  = "Label",         -- Field
	[6]  = "@variable",     -- Variable
	[7]  = "Type",          -- Class
	[8]  = "Type",          -- Interface
	[9]  = "PreProc",       -- Module
	[10] = "Label",         -- Property
	[11] = "Number",        -- Unit
	[12] = "Number",        -- Value
	[13] = "Type",          -- Enum
	[14] = "Keyword",       -- Keyword
	[15] = "Special",       -- Snippet
	[16] = nil,             -- Color (preserve built-in)
	[17] = "Directory",     -- File
	[18] = "StorageClass",  -- Reference
	[19] = "Directory",     -- Folder
	[20] = "Constant",      -- EnumMember
	[21] = "Constant",      -- Constant
	[22] = "Type",          -- Struct
	[23] = "Special",       -- Event
	[24] = "Operator",      -- Operator
	[25] = "Type",          -- TypeParameter
}

local completion_bt_blocklist = { prompt = true, terminal = true }
local completion_ft_blocklist = { TelescopePrompt = true }

local function should_skip_completion()
	return completion_bt_blocklist[vim.bo.buftype]
		or completion_ft_blocklist[vim.bo.filetype]
end

--- Clean null bytes and excessive whitespace from LSP completion text
local function clean_lsp_text(s, max_len)
	if not s or s == "" then
		return nil
	end
	s = s:gsub("%z", " ")
	s = s:gsub("%s+", " ")
	s = s:match("^%s*(.-)%s*$") or s
	if max_len and #s > max_len then
		s = s:sub(1, max_len - 3) .. "..."
	end
	return s
end

--- Query LuaSnip for snippets matching the current prefix
local function get_luasnip_items(prefix)
	local ok, ls = pcall(require, "luasnip")
	if not ok then
		return {}
	end
	local items = {}
	local seen = {}
	for _, ft in ipairs({ vim.bo.filetype, "all" }) do
		for _, snip in ipairs(ls.get_snippets(ft) or {}) do
			if not seen[snip.trigger] and snip.trigger:find(prefix, 1, true) == 1 then
				seen[snip.trigger] = true
				table.insert(items, {
					word = snip.trigger,
					kind = " Snippet",
					menu = snip.name ~= snip.trigger and snip.name or "",
					user_data = { luasnip = true },
					match = true,
				})
			end
		end
	end
	return items
end

--- Get the word prefix before the cursor
local function get_prefix()
	local col = vim.fn.col(".") - 1
	if col == 0 then
		return "", 0
	end
	local line = vim.fn.getline(".")
	local prefix = line:sub(1, col):match("[%w_]+$") or ""
	return prefix, col - #prefix + 1
end

local function get_completion_user_data(item)
	local ud = item and item.user_data
	if type(ud) == "table" then
		return ud
	end
	if type(ud) ~= "string" or ud == "" then
		return {}
	end

	local ok, decoded = pcall(vim.json.decode, ud)
	if not ok or type(decoded) ~= "table" then
		return {}
	end
	return decoded
end

-- Route LSP snippet expansion through LuaSnip
vim.snippet.expand = function(body)
	require("luasnip").lsp_expand(body)
end

-- Enable LSP completion on attach
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, {
				autotrigger = true,
				convert = function(item)
					local result = {}

					local label = item.label or ""
					local label_detail = vim.tbl_get(item, "labelDetails", "detail") or ""
					local abbr = clean_lsp_text(label .. label_detail, 80)
					if abbr then
						result.abbr = abbr
					end

					local menu_text = vim.tbl_get(item, "labelDetails", "description") or item.detail or ""
					local menu = clean_lsp_text(menu_text, 50)
					if menu then
						result.menu = menu
					end

					local hl = kind_hl_map[item.kind]
					if hl then
						result.kind_hlgroup = hl
					end

					return result
				end,
			})
		end
	end,
})

-- Expand LuaSnip snippet when selected from completion popup
vim.api.nvim_create_autocmd("CompleteDone", {
	callback = function()
		local item = vim.v.completed_item
		if not item then
			return
		end
		local ud = get_completion_user_data(item)
		if not ud.luasnip then
			return
		end
		local ls = require("luasnip")
		local word = item.word or ""
		if word == "" then
			return
		end
		-- Find the matching snippet and expand it
		for _, ft in ipairs({ vim.bo.filetype, "all" }) do
			for _, snip in ipairs(ls.get_snippets(ft) or {}) do
				if snip.trigger == word then
					-- Remove the inserted trigger word
					local row = vim.fn.line(".")
					local col = vim.fn.col(".")
					local line = vim.fn.getline(".")
					local before = line:sub(1, col - 1 - #word)
					local after = line:sub(col)
					vim.fn.setline(row, before .. after)
					vim.api.nvim_win_set_cursor(0, { row, #before })
					-- Expand the snippet
					ls.snip_expand(snip:copy())
					return
				end
			end
		end
	end,
})

local function get_path_context()
	local col = vim.fn.col(".") - 1
	if col == 0 then
		return nil
	end

	local before_cursor = vim.fn.getline("."):sub(1, col)
	local token_start, token = before_cursor:match("()([^%s\"'`]+)$")
	if not token or not token:find("/", 1, true) then
		return nil
	end

	local slash = token:match("^.*()/")
	if not slash then
		return nil
	end

	local dir = token:sub(1, slash)
	local prefix = token:sub(slash + 1)
	return {
		dir = dir,
		prefix = prefix,
		start_col = token_start + slash,
	}
end

local function complete_path(ctx)
	local expanded_dir = vim.fn.expand(ctx.dir)
	if expanded_dir == "" then
		return
	end

	local ok, scanner = pcall(vim.uv.fs_scandir, expanded_dir)
	if not ok or not scanner then
		return
	end

	local items = {}
	local prefix = ctx.prefix
	local show_hidden = prefix:sub(1, 1) == "."

	while true do
		local next_ok, name, typ = pcall(vim.uv.fs_scandir_next, scanner)
		if not next_ok then
			return
		end
		if not name then
			break
		end
		if (show_hidden or name:sub(1, 1) ~= ".") and name:find(prefix, 1, true) == 1 then
			local is_dir = typ == "directory"
			table.insert(items, {
				word = is_dir and (name .. "/") or name,
				abbr = name,
				kind = is_dir and " Folder" or " File",
				kind_hlgroup = "Directory",
				menu = ctx.dir,
				dup = 0,
			})
		end
	end

	if #items == 0 then
		return
	end

	table.sort(items, function(a, b)
		if a.kind ~= b.kind then
			return a.kind == " Folder"
		end
		return a.word < b.word
	end)
	vim.fn.complete(ctx.start_col, items)
end

local function try_complete_path()
	local ok_ctx, ctx = pcall(get_path_context)
	if not ok_ctx or not ctx then
		return false
	end

	pcall(complete_path, ctx)
	return true
end

-- Auto-trigger completion only when typing word characters
vim.api.nvim_create_autocmd("TextChangedI", {
	callback = function()
		if vim.fn.pumvisible() == 1 then
			return
		end
		if should_skip_completion() then
			return
		end
		local col = vim.fn.col(".") - 1
		if col == 0 then
			return
		end

		if try_complete_path() then
			return
		end

		local char = vim.fn.getline("."):sub(col, col)
		if char:match("[%w_%.%:%->]") then
			-- Inject LuaSnip items first, LSP will merge via prev_matches
			local prefix, start_col = get_prefix()
			if #prefix > 0 then
				local snip_items = get_luasnip_items(prefix)
				if #snip_items > 0 then
					vim.fn.complete(start_col, snip_items)
				end
			end
			vim.lsp.completion.get()
		end
	end,
})

-- <CR> never accepts completion; only <C-y> does. Close popup and insert newline.
vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-e><CR>"
	end
	return "<CR>"
end, { expr = true })

vim.keymap.set("i", "<C-space>", function()
	if should_skip_completion() then
		return
	end
	if try_complete_path() then
		return
	end
	local prefix, start_col = get_prefix()
	if #prefix > 0 then
		local snip_items = get_luasnip_items(prefix)
		if #snip_items > 0 then
			vim.fn.complete(start_col, snip_items)
		end
	end
	vim.lsp.completion.get()
end)
