vim.o.completeopt = "menuone,noinsert,popup"
vim.o.pumheight = 12
vim.o.pumblend = 0
vim.o.pumborder = "rounded"

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

local function is_path_trigger()
	local col = vim.fn.col(".") - 1
	if col == 0 then
		return false
	end
	local before_cursor = vim.fn.getline("."):sub(1, col)
	return before_cursor:match("[%.~/]/?[%.~/]*/%S*$") ~= nil
		or before_cursor:match("%S+/%S*$") ~= nil
end

-- Auto-trigger completion only when typing word characters
vim.api.nvim_create_autocmd("TextChangedI", {
	callback = function()
		if vim.fn.pumvisible() == 1 then
			return
		end
		local col = vim.fn.col(".") - 1
		if col == 0 then
			return
		end

		if is_path_trigger() then
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-x><C-f>", true, false, true),
				"n",
				false
			)
			return
		end

		local char = vim.fn.getline("."):sub(col, col)
		if char:match("[%w_%.%:%->]") then
			vim.lsp.completion.get()
		end
	end,
})

vim.keymap.set("i", "<C-space>", function()
	vim.lsp.completion.get()
end)
