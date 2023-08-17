local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local partial = require("luasnip.extras").partial
local s = ls.s --> snippet
local i = ls.i --> insert node
local t = ls.t --> textnode

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node

local curl_get = s(
	"curl_get",
	fmt(
		[[
curl -s -X GET \
-H "Content-Type: application/json" \
-u {}:{} \
{}/api/
		]],
		{ i(1,"user"), i(2,"token"),  i(3,"url") }
	)
)

local curl_post = s(
	"curl_post",
	fmt(
		[[
curl -s -X POST \
-H "Content-Type: application/json" \
-u {}:{} \
-d '{}' \
{}/api/
		]],
		{ i(1,"user"), i(2,"token"), i(3,"{\"foo\":\"bar\"}"),  i(4,"url") }
	)
)

return {
	curl_get,
	curl_post,
	s("time", partial(vim.fn.strftime, "%H:%M:%S")),
	s("date", partial(vim.fn.strftime, "%Y-%m-%d")),
	s("shrug", { ls.t("¯\\_(ツ)_/¯") }),
	s("angry", { ls.t("(╯°□°）╯︵ ┻━┻") }),
	s("happy", { ls.t("ヽ(´▽`)/") }),
	s("sad", { ls.t("(－‸ლ)") }),
	s("confused", { ls.t("(｡･ω･｡)") }),
}
