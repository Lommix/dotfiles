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

-- Main {{{
local comp = s(
	"compd",
	fmt(
[[
#[derive(Component)]
pub struct {}
]],
		{ i() }
	)
)
table.insert(snippets, comp)
-- }}}

local compe = s(
	"compd",
	fmt(
[[
#[derive(Component, Clone, Copy, Reflect, FromReflect, Debug)]
pub struct {}
]],
		{ i() }
	)
)
table.insert(snippets, compe)

return snippets
