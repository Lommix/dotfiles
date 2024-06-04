local ls = require("luasnip")
local s = ls.s --> snippet
local i = ls.i --> insert node
local t = ls.t --> textnode

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node

local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt
local log = require("lommix.log")

local tsutil = require("nvim-treesitter.ts_utils")
local parsers = require "nvim-treesitter.parsers"
local utils = require "nvim-treesitter.utils"
local ts = vim.treesitter

local snippets = {}


---@param node TSNode
---@param type string
---@return TSNode|nil
local function find_next(node, type)
	local function next_node(n)
		-- Try to go to the first child
		local next_n = n:named_child(0)
		if next_n then return next_n end
		-- Try to go to the next sibling
		next_n = n:next_named_sibling()
		if next_n then return next_n end
		-- Go up to the parent and try to find a sibling there
		next_n = n:parent()
		while next_n do
			local sibling = next_n:next_named_sibling()
			if sibling then return sibling end
			next_n = next_n:parent()
		end
		return nil
	end
	-- Start from the given node and search for the next identifier
	local current_node = node
	while current_node do
		current_node = next_node(current_node)
		if current_node and current_node:type() == type then
			return current_node
		end
	end
	return nil
end


---@return string
local function next_identifier()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	local node = vim.treesitter.get_node({
		bufnr = 0,
		pos = { line, col },
	})

	local identifier = find_next(node, "identifier")
	if identifier ~= nil then
		local text = tsutil.get_node_text(identifier, 0)
		return text[1]
	end

	return "name"
end

-- JSdoc type snippet
local jsdoc_type = s(
	"ty",
	fmt(
		[[
/** @type {{{}}} {} */
]],
		{ i(1, "type"), f(next_identifier) }
	)
)
table.insert(snippets, jsdoc_type)


return snippets
