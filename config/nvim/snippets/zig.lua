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
-- local ts = require("nvim-treesitter")
-- local ts_locals = require("nvim-treesitter.locals")
-- local ts_utils = require("nvim-treesitter.ts_utils")

local snippets = {}

local plugin = s(
	"plugin",
	fmt(
		[[const std = @import("std");
const r = @import("root.zig");
const kn = r.kn;
const m = r.lm.Math;



pub fn plugin(app: *kn.App) !void {{
    _ = app;
}}
]],
		{ }
	)
)
table.insert(snippets, plugin)

local sys = s(
	"sys",
	fmt(
		[[
fn {}(world: *World) !void {{
	{}
}}
]],
		{ i(1), i(2) }
	)
)
table.insert(snippets, sys)

local lam = s(
	"lam",
	fmt(
		[[
	(struct{{
		fn {}({})void{{
		}}
	}}).{}
]],
		{ i(1), i(2), rep(1) }
	)
)
table.insert(snippets, lam)

return snippets
