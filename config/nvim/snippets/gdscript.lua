local ls = require("luasnip")
local s = ls.s --> snippet
local i = ls.i --> insert node
local t = ls.t --> textnode

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node

local fmt = require("luasnip.extras.fmt").fmt
local ts = require("nvim-treesitter")
local ts_locals = require("nvim-treesitter.locals")
local ts_utils = require("nvim-treesitter.ts_utils")

local snippets = {}
local autosnippets = {}

local same = function(index)
	return f(function(arg)
		return arg[1]
	end, { index })
end

-- Seperator Block {{{
local sepblock = s(
	"sep",
	fmt(
		[[
################################################################
# {}
################################################################
		]],
		{ i(1, "block") }
	)
)
table.insert(snippets, sepblock)
-- }}}

-- Seperator Block {{{
local classblock = s(
	"cl",
	fmt(
		[[
## Class : {3}
##
## Lommix Software
## @author: Lorenz Mielke 2023
class_name {1}
extends {2}


################################################################
# signals
################################################################



################################################################
# const
################################################################



################################################################
# public
################################################################



################################################################
# private
################################################################



func _ready() -> void:
	pass
		]],
		{
			i(1, "class"),
			c(2, { t("Node"), t("Node2D") }),
			same(1),
		}
	)
)

table.insert(snippets, classblock)
-- }}}

local get_params = function()
	return f(function(arg1, snip, arg3)
		local cursor = vim.api.nvim_win_get_cursor(0)
		local buffer = vim.api.nvim_get_current_buf()

		for i = 0, 10, 1 do
			local fn_node = vim.treesitter.get_node_at_pos(buffer, cursor[1] + i, cursor[2])
			if fn_node:type() == "function_definition" then
				local rt = {}
				local fn_table = ts_utils.get_named_children(fn_node)
				local name = ts_utils.get_node_text(fn_table[1])[1]
				local params = ts_utils.get_node_text(fn_table[2])[1]
				local ret = ts_utils.get_node_text(fn_table[3])[1]


				params = string.gsub(params, "[()]", "")
				for match in (params..","):gmatch("(.-)".. ",") do
					table.insert(rt, "## @arg ".. vim.fn.trim(match))
				end

				if fn_table[3]:type() == "return_type" then
					ret = string.gsub(ret, "->", "")
					table.insert(rt, "## @return " ..  vim.fn.trim(ret))
				else

					table.insert(rt, "## @return void")
				end

				do
					return rt
				end
			end
		end
	end)
end
-- Function Doc Block {{{
local fdoc = s(
	"fdoc",
	fmt(
		[[
## {}
{}
]],
		{
			i(1, "description"),
			get_params(),
		}
	)
)
table.insert(snippets, fdoc)

return snippets, autosnippets
