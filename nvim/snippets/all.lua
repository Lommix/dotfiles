local ls = require("luasnip")
local partial = require("luasnip.extras").partial
local s = ls.s --> snippet
local i = ls.i --> insert node
local t = ls.t --> textnode

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node

return {
	s("time", partial(vim.fn.strftime, "%H:%M:%S")),
	s("date", partial(vim.fn.strftime, "%Y-%m-%d")),
	s("shrug", { ls.t("¯\\_(ツ)_/¯") }),
	s("angry", { ls.t("(╯°□°）╯︵ ┻━┻") }),
	s("happy", { ls.t("ヽ(´▽`)/") }),
	s("sad", { ls.t("(－‸ლ)") }),
	s("confused", { ls.t("(｡･ω･｡)") }),
}

