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

local plugin = s(
	"plugin",
	fmt(
		[[
pub fn plugin(world: *Core.Ecs) !void {{
	try world.systems.register({});
}}
]],
		{ i(1) }
	)
)
table.insert(snippets, plugin)

local sys = s(
	"sys",
	fmt(
		[[
fn {}(world: *Core.Ecs) !void {{
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
-- const func = (struct {
--     fn t(ev: Event, world: *Ecs) void {
--         _ = world;
--         std.debug.print("hello from event {d}!\n", .{ev.foo});
--     }
-- }).t;

-- local bevy_plguin = s(
-- 	"plugin",
-- 	fmt(
-- 		[[
-- use bevy::prelude::*;
-- pub struct {};
-- impl Plugin for {} {{
--     fn build(&self, app: &mut App) {{
--     }}
-- }}
-- ]],
-- 		{ i(1), rep(1) }
-- 	)
-- )
--
-- table.insert(snippets, bevy_plguin)

return snippets
