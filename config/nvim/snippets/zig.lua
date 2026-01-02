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
		[[const std = @import("std");
const pre = @import("../pre.zig");
const kn = pre.Knoedel;
const m = pre.Math;



pub fn plugin(world: *kn.App) !void {{
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

-- Helper function to get enum fields from LSP
local get_enum_fields = function(enum_name)
	if not enum_name or enum_name == "" then
		return {}
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_active_clients({ bufnr = bufnr })

	for _, client in ipairs(clients) do
		if client.server_capabilities.documentSymbolProvider then
			local params = { textDocument = vim.lsp.util.make_text_document_params() }
			local result = client.request_sync("textDocument/documentSymbol", params, 2000, bufnr)

			if result and result.result then
				-- Recursively search for the enum/union
				local function find_enum(symbols, name)
					for _, symbol in ipairs(symbols) do
						if symbol.name == name then
							return symbol
						end
						if symbol.children then
							local found = find_enum(symbol.children, name)
							if found then
								return found
							end
						end
					end
					return nil
				end

				local enum_symbol = find_enum(result.result, enum_name)
				if enum_symbol and enum_symbol.children then
					local fields = {}
					for _, child in ipairs(enum_symbol.children) do
						-- EnumMember (22) or Field (5) for tagged unions
						if child.kind == 22 or child.kind == 5 then
							table.insert(fields, child.name)
						end
					end
					return fields
				end
			end
		end
	end
	return {}
end

-- Helper to find variable type using tree-sitter
local get_variable_type = function(var_name)
	if not var_name or var_name == "" then
		return nil
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "zig")
	if not ok or not parser then
		return nil
	end

	local trees = parser:parse()
	if not trees or #trees == 0 then
		return nil
	end

	local tree = trees[1]
	local root = tree:root()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local cursor_row = cursor_pos[1] - 1

	-- Find parameters and variable_declarations
	local query_str = [[
		(parameter) @param
		(variable_declaration) @var_decl
	]]

	local ok2, query = pcall(vim.treesitter.query.parse, "zig", query_str)
	if not ok2 then
		return nil
	end

	-- Search backwards from cursor for variable declaration
	for id, node in query:iter_captures(root, bufnr, 0, cursor_row + 1) do
		local node_type = node:type()

		-- Get all children
		local children = {}
		for child in node:iter_children() do
			table.insert(children, {
				type = child:type(),
				text = vim.treesitter.get_node_text(child, bufnr),
			})
		end

		-- For parameters: identifier ":" type
		if node_type == "parameter" and #children >= 3 then
			local name = children[1]
			local type_node = children[3]

			if name.type == "identifier" and name.text == var_name then
				-- The type is the third child (after identifier and ":")
				local type_text = type_node.text

				-- Extract type name, handling pointers and other decorators
				local type_name = type_text:match("%*?%s*const%s+([%w_]+)")
					or type_text:match("%*%s*([%w_]+)")
					or type_text:match("^([%w_]+)")

				if type_name then
					return type_name
				end
			end
		end

		-- For variable declarations: var/const identifier ":" type "=" value
		if node_type == "variable_declaration" then
			for i, child in ipairs(children) do
				if child.type == "identifier" and child.text == var_name then
					-- Look for type after the identifier
					for j = i + 1, #children do
						if children[j].type == "identifier" or children[j].type == "type_expression" then
							local type_text = children[j].text

							local type_name = type_text:match("%*?%s*const%s+([%w_]+)")
								or type_text:match("%*%s*([%w_]+)")
								or type_text:match("^([%w_]+)")

							if type_name then
								return type_name
							end
						end
					end
				end
			end
		end
	end

	return nil
end

local sw = s("sw", {
	t("switch ("),
	i(1, "value"),
	t({ ") {", "" }),
	d(2, function(args)
		local input = args[1][1] or ""
		local enum_type = nil

		-- Try multiple strategies to get the enum type:

		-- 1. Check if user provided explicit type hint "value: EnumType"
		local type_hint = input:match(":%s*([%w_%.]+)")
		if type_hint then
			enum_type = type_hint:match("([%w_]+)$") or type_hint
		end

		-- 2. Try to use the input as the type name directly (for cases like "State" or "MyEnum")
		if not enum_type then
			local potential_type = input:match("^([%w_]+)$")
			if potential_type and potential_type:match("^[A-Z]") then
				-- Looks like a type name (starts with capital)
				enum_type = potential_type
			end
		end

		-- 3. Try tree-sitter to find variable type (for variables like "self", "state", etc.)
		if not enum_type then
			enum_type = get_variable_type(input)
		end

		-- Query LSP for enum fields
		local fields = {}
		if enum_type then
			fields = get_enum_fields(enum_type)
		end

		-- Generate switch cases
		local nodes = {}
		if #fields > 0 then
			for idx, field in ipairs(fields) do
				table.insert(nodes, t({ "    ." .. field .. " => {},", "" }))
			end
		else
			-- Fallback if no fields found - create template
			table.insert(nodes, t("    ."))
			table.insert(nodes, i(1, "case"))
			table.insert(nodes, t({ " => {},", "" }))
		end

		return sn(nil, nodes)
	end, { 1 }),
	t("}"),
})
table.insert(snippets, sw)

return snippets
