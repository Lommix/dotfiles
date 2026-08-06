local M = {}

M.ocr = blitz.register_tool({
	name = "lua_view_image",
	description = "View any image and get a detailed OCR description back. Provide a prompt for a more detailed report",
	args = {
		path = { type = "string", description = "the image path or url", required = true },
		prompt = { type = "string", description = "optional question" },
	},
	func = function(ctx, call)
		local ocr_url = "http://127.0.0.1:8119/v1/chat/completions"
		local model = "ggml-org/GLM-OCR-GGUF:Q8_0"

		local path = call.arguments.path
		if type(path) ~= "string" or path == "" then
			return blitz.err("path is required")
		end
		local prompt = call.arguments.prompt
		if type(prompt) ~= "string" or prompt == "" then
			prompt = "OCR"
		end

		ctx:set_status("viewing " .. path)

		local image_url = path
		if not path:match("^https?://") then
			local b64, ok = blitz.shell("base64 -w0 '" .. path .. "'")
			if not ok or b64 == nil or b64 == "" then
				return blitz.err("failed to read image: " .. path)
			end
			image_url = "data:image/png;base64," .. (b64:gsub("%s+", ""))
		end

		local payload, ok = blitz.json.encode({
			model = model,
			messages = {
				{
					role = "user",
					content = {
						{ type = "text", text = prompt },
						{ type = "image_url", image_url = { url = image_url } },
					},
				},
			},
		})
		if ok == false then
			return blitz.err("failed to build ocr request")
		end

		local tmp = os.tmpname()
		local f = assert(io.open(tmp, "w"))
		f:write(payload)
		f:close()

		local body, ok =
			blitz.shell("curl -sS --max-time 30 -H 'Content-Type: application/json' -d @" .. tmp .. " " .. ocr_url)
		os.remove(tmp)
		if not ok then
			return blitz.err("ocr request failed (curl exit non-zero)")
		end

		local val, ok = blitz.json.decode(body)
		if ok == false then
			return blitz.err("failed to parse ocr json response")
		end

		local text = val
			and val.choices
			and val.choices[1]
			and val.choices[1].message
			and val.choices[1].message.content
		if type(text) ~= "string" or text == "" then
			return blitz.err("OCR returned empty content")
		end

		return blitz.ok(text)
	end,
})

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
		local content, ok = blitz.shell("yomi read " .. url)

		if not ok or content == nil or content == "" then
			return blitz.err("chromium returned no output")
		end

		return blitz.ok(content)
	end,
})

-------------------------------------------------------------------------------------------------
--- Web search with Brave
-------------------------------------------------------------------------------------------------
M.web_search = blitz.register_tool({
	name = "lua_web_search",
	description = "Search the web with Brave. Supports Brave query operators such as site: and filetype:.",
	args = {
		searchQuery = { type = "string", description = "the search query", required = true },
		max_results = { type = "number", description = "maximum results to return (default 10, max 20)" },
	},
	func = function(ctx, call)
		local query = call.arguments.searchQuery
		if type(query) ~= "string" or query == "" then
			return blitz.err("searchQuery is required")
		end

		local api_key = os.getenv("BRAVE_API_KEY")
		if type(api_key) ~= "string" or api_key == "" then
			return blitz.err("BRAVE_API_KEY is not set")
		end
		if api_key:find("[%c]") then
			return blitz.err("BRAVE_API_KEY contains invalid control characters")
		end

		ctx:set_status("search " .. query)

		local max = tonumber(call.arguments.max_results) or 10
		if max < 1 then
			max = 1
		end
		if max > 20 then
			max = 20
		end

		-- RFC 3986 percent-encode (unreserved set kept literal)
		local function urlencode(s)
			s = (s:gsub("[%c]", " "))
			local rep
			rep = function(c)
				return string.format("%%%02X", string.byte(c))
			end
			return (s:gsub("([^%w%-_%.~])", rep))
		end

		local search_url = "https://api.search.brave.com/res/v1/web/search?q="
			.. urlencode(query)
			.. "&count="
			.. max
			.. "&result_filter=web&text_decorations=false&extra_snippets=true"

		local body, ok = blitz.shell(
			"curl -sS --max-time 15 -H 'Accept: application/json' -H \"X-Subscription-Token: $BRAVE_API_KEY\" '"
				.. search_url
				.. "'"
		)
		if not ok then
			return blitz.err("brave request failed (curl exit non-zero)")
		end
		if type(body) ~= "string" or body == "" then
			return blitz.err("Brave Search returned an empty response")
		end

		local val, ok = blitz.json.decode(body)
		if ok == false then
			return blitz.err("failed to parse brave json response")
		end
		if type(val) == "table" and type(val.error) == "table" then
			return blitz.err(
				"Brave Search failed: " .. tostring(val.error.detail or val.error.message or "unknown API error")
			)
		end

		local results = type(val) == "table" and type(val.web) == "table" and val.web.results or nil
		if type(results) ~= "table" or #results == 0 then
			return blitz.ok("No results for: " .. query)
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
			local snippet = clean(r.description)
			if #snippet > 500 then
				snippet = snippet:sub(1, 500) .. "..."
			end
			lines[#lines + 1] = string.format("[%d] %s", idx, title)
			lines[#lines + 1] = "    " .. tostring(r.url or "")
			lines[#lines + 1] = "    " .. snippet
			if type(r.extra_snippets) == "table" then
				for _, extra in ipairs(r.extra_snippets) do
					extra = clean(extra)
					if extra ~= "" then
						lines[#lines + 1] = "    More: " .. extra
					end
				end
			end
			lines[#lines + 1] = ""
		end

		return blitz.ok(table.concat(lines, "\n"))
	end,
})

return M
