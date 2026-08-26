local M = {}

-------------------------------------------------------------------------------------------------
--- Image generation tool
-------------------------------------------------------------------------------------------------
M.gen_image = blitz.register_tool({
	name = "lua_gen_image",
	description = [[
    Generate an image from prompt. Returned format is webp! Prompting best practices:
    Structure prompt as scene/backdrop -> subject -> details -> constraints.
    Include intended use (ad, UI mock, infographic) to set the mode and polish level.
    Use camera/composition language for photorealism.
    Only use SVG/vector stand-ins when the user explicitly asked for vector output or a non-image placeholder.
    Quote exact text and specify typography + placement.
    For tricky words, spell them letter-by-letter and require verbatim rendering.
    For multi-image inputs, reference images by index and describe how they should be used.
    For edits, repeat invariants every iteration to reduce drift.
    Iterate with single-change follow-ups.
    If the prompt is generic, add only the extra detail that will materially help.
    If the prompt is already detailed, normalize it instead of expanding it.
    ]],
	args = {
		path = { type = "string", description = "where to save the webp image", required = true },
		prompt = { type = "string", description = "the generation prompt", required = true },
		size = { type = "string", description = "image size as WxH, e.g. 512x512 (default 512x512)" },
	},
	func = function(ctx, call)
		local path = call.arguments.path
		if type(path) ~= "string" or path == "" then
			error("path is required")
		end
		local prompt = call.arguments.prompt
		if type(prompt) ~= "string" or prompt == "" then
			error("prompt is required")
		end
		local size = call.arguments.size
		if type(size) ~= "string" or size == "" then
			size = "512*512"
		else
			size = size:gsub("x", "*")
		end

		local api_key = os.getenv("NOVITA_API_KEY")
		if type(api_key) ~= "string" or api_key == "" then
			error("NOVITA_API_KEY is not set")
		end
		if api_key:find("[%c]") then
			error("NOVITA_API_KEY contains invalid control characters")
		end

		ctx:set_status("gen image `" .. prompt .. "`")

		local payload, ok = blitz.json.encode({
			seed = 101,
			size = size,
			prompt = prompt,
			output_format = "webp",
			enable_base64_output = false,
		})
		if ok == false then
			error("failed to build image request")
		end

		local tmp = os.tmpname()
		local f = assert(io.open(tmp, "w"))
		f:write(payload)
		f:close()

		local body, ok = blitz.shell(
			"curl -sS --max-time 30 -X POST 'https://api.novita.ai/v3/async/z-image-turbo'"
				.. " -H 'Content-Type: application/json'"
				.. ' -H "Authorization: Bearer $NOVITA_API_KEY"'
				.. " -d @"
				.. tmp
		)
		os.remove(tmp)
		if not ok then
			error("image request failed (curl exit non-zero)")
		end

		local val, ok = blitz.json.decode(body)
		if ok == false then
			error("failed to parse image json response")
		end

		local task_id = val.task_id or (val.task and val.task.task_id) or (val.data and val.data.task_id)
		if type(task_id) ~= "string" or task_id == "" then
			error("novita did not return a task_id: " .. tostring(body))
		end

		ctx:set_status("novita task " .. task_id .. " pending")

		local result_url = "https://api.novita.ai/v3/async/task-result?task_id=" .. task_id
		local image_url
		for _ = 1, 60 do
			os.execute("sleep 2")
			local res, ok =
				blitz.shell('curl -sS --max-time 30 -H "Authorization: Bearer $NOVITA_API_KEY" \'' .. result_url .. "'")
			if not ok then
				error("task-result request failed (curl exit non-zero)")
			end
			local r, ok = blitz.json.decode(res)
			if ok == false then
				error("failed to parse task-result json response")
			end
			local status = r.task and r.task.status or ""
			if status == "TASK_STATUS_SUCCEED" then
				local imgs = r.images
				if type(imgs) == "table" and imgs[1] and imgs[1].image_url then
					image_url = imgs[1].image_url
					break
				end
				error("novita task succeeded but no image url found: " .. tostring(res))
			elseif status == "TASK_STATUS_FAILED" then
				local reason = r.task and r.task.reason or "unknown"
				error("novita task failed: " .. tostring(reason))
			end
		end

		if not image_url then
			error("novita task timed out: " .. task_id)
		end

		ctx:set_status("downloading image to `" .. path .. "`")

		local _, ok = blitz.shell("curl -sS --max-time 30 -o '" .. path .. "' '" .. image_url .. "'")
		if not ok then
			error("failed to download image to: " .. path)
		end

		return { msg = "image saved to " .. path }
	end,
})

-------------------------------------------------------------------------------------------------
--- CUSTOM TOOLS: Lua repl for math
-------------------------------------------------------------------------------------------------
M.lua_repl = blitz.register_tool({
	name = "lua_repl",
	description = "Execute arbitrary Lua code and return the result. Runs inside the blitzdenk Lua VM",
	args = {
		code = { type = "string", description = "Lua code to execute", required = true },
	},
	func = function(ctx, call)
		local orange = "\27[38;5;208m"
		local bold = "\27[1m"
		local reset = "\27[0m"

		ctx:set_status(orange .. bold .. "(Lua)" .. reset .. " `" .. call.arguments.code .. "`")

		local fn, err = load(call.arguments.code)
		if not fn then
			error(err)
		end

		local ok, result = pcall(fn)
		if not ok then
			error(tostring(result))
		end

		return { msg = tostring(result or "nil") }
	end,
})

-------------------------------------------------------------------------------------------------
--- Web fetch with yomi
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
			error("url is required")
		end

		ctx:set_status("fetch " .. url)
		local content, ok = blitz.shell("yomi read " .. url)

		if not ok or content == nil or content == "" then
			error("chromium returned no output")
		end

		return { msg = content }
	end,
})

-------------------------------------------------------------------------------------------------
--- Web search with Brave API
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
			error("searchQuery is required")
		end

		local api_key = os.getenv("BRAVE_API_KEY")
		if type(api_key) ~= "string" or api_key == "" then
			error("BRAVE_API_KEY is not set")
		end
		if api_key:find("[%c]") then
			error("BRAVE_API_KEY contains invalid control characters")
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
			error("brave request failed (curl exit non-zero)")
		end
		if type(body) ~= "string" or body == "" then
			error("Brave Search returned an empty response")
		end

		local val, ok = blitz.json.decode(body)
		if ok == false then
			error("failed to parse brave json response")
		end
		if type(val) == "table" and type(val.error) == "table" then
			error("Brave Search failed: " .. tostring(val.error.detail or val.error.message or "unknown API error"))
		end

		local results = type(val) == "table" and type(val.web) == "table" and val.web.results or nil
		if type(results) ~= "table" or #results == 0 then
			return { msg = "No results for: " .. query }
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

		return { msg = table.concat(lines, "\n") }
	end,
})

return M
