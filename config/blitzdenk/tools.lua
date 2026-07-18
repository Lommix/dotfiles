local M = {}
-------------------------------------------------------------------------------------------------
--- CUSTOM TOOLS: Lua repl for math
-------------------------------------------------------------------------------------------------
M.lua_repl = blitz.register_tool({
	name = "lua_repl",
	description = "Execute arbitrary Lua code and return the result. Use this tool for any math calculations",
	args = {
		code = { type = "string", description = "Lua code to execute", required = true },
	},
	func = function(ctx, call)
		ctx:set_status("(Lua) `" .. call.arguments.code .. "`")

		local fn, err = load(call.arguments.code)
		if not fn then
			return blitz.err(err)
		end

		local ok, result = pcall(fn)
		if not ok then
			return blitz.err(tostring(result))
		end

		return blitz.ok(tostring(result or "nil"))
	end,
})

-------------------------------------------------------------------------------------------------
--- Web fetch with chromium,
--- without protection
-------------------------------------------------------------------------------------------------
M.web_fetch = blitz.register_tool({
	name = "lua_webfetch",
	description = "performs a web fetch and returns the content as markdown",
	args = {
		url = { type = "string", description = "the url to fetch", required = true },
	},
	func = function(ctx, call)
		local url = call.arguments.url
		if type(url) ~= "string" or url == "" then
			return blitz.err("url is required")
		end

		ctx:set_status("fetch " .. url)

		-- headless chromium with virtual-time-budget for SPA rendering.
		-- convert to pdf -> convert pdf to text.
		-- It is not efficient, nor secure, but it works very well and is easy
		local content, ok = blitz.shell(
			"chromium --headless=new --disable-gpu --no-sandbox "
				.. "--virtual-time-budget=3000 "
				.. "--print-to-pdf=/dev/stdout --no-margins "
				.. url
				.. " 2>/dev/null"
				.. " | pdftotext - -"
		)

		if not ok or content == nil or content == "" then
			return blitz.err("chromium returned no output")
		end

		return blitz.ok(content)
	end,
})

-------------------------------------------------------------------------------------------------
--- Web search with searXNG
-------------------------------------------------------------------------------------------------
M.web_search = blitz.register_tool({
	name = "lua_web_search",
	description = "Search the web via a local SearXNG instance",
	args = {
		searchQuery = { type = "string", description = "the search query", required = true },
		max_results = { type = "number", description = "maximum results to return (default 10, max 20)" },
	},
	func = function(ctx, call)
		local query = call.arguments.searchQuery
		if type(query) ~= "string" or query == "" then
			return blitz.err("searchQuery is required")
		end

		ctx:set_status("search " .. query)

		-- RFC 3986 percent-encode (unreserved set kept literal)
		local function urlencode(s)
			s = (s:gsub("[%c]", " "))
			local rep
			rep = function(c)
				return string.format("%%%02X", string.byte(c))
			end
			return (s:gsub("([^%w%-_%.~])", rep))
		end

		local api = "http://127.0.0.1:8080/search?q={s}&format=json"
		local serach_url = (api:gsub("{s}", function()
			return urlencode(query)
		end))

		local body, ok = blitz.shell("curl -sS --max-time 15 '" .. serach_url .. "'")
		if not ok then
			return blitz.err("searxng request failed (curl exit non-zero)")
		end
		if type(body) ~= "string" or body == "" then
			return blitz.err("searxng returned empty body")
		end

		local val, ok = blitz.json.decode(body)

		if ok == false then
			return blitz.err("failed to parse searxng json response")
		end

		local results = type(val) == "table" and val.results or nil
		if type(results) ~= "table" or #results == 0 then
			return blitz.ok("No results for: " .. query)
		end

		local max = tonumber(call.arguments.max_results) or 10
		if max < 1 then
			max = 1
		end
		if max > 20 then
			max = 20
		end
		if max > #results then
			max = #results
		end

		-- Strip HTML tags + decode common entities, collapse whitespace
		local function clean(s)
			if type(s) ~= "string" then
				return ""
			end
			s = s:gsub("<[^>]*>", " ")
			s = s:gsub("&[a-zA-Z#0-9]+;", " ")
			s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
			return s
		end

		local lines = { "Search results for: " .. query, "" }
		for idx = 1, max do
			local r = results[idx]
			local title = clean(r.title)
			if title == "" then
				title = "(no title)"
			end
			local url = r.url or ""
			local snippet = clean(r.content)
			if #snippet > 500 then
				snippet = snippet:sub(1, 500) .. "..."
			end
			lines[#lines + 1] = string.format("[%d] %s", idx, title)
			lines[#lines + 1] = "    " .. url
			lines[#lines + 1] = "    " .. snippet
			lines[#lines + 1] = ""
		end

		return blitz.ok(table.concat(lines, "\n"))
	end,
})

return M
