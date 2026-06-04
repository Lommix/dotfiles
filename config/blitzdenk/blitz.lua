-- BLITZCLOUD CFG
blitz.set_compact_edge(200000)

local llama = blitz.add_provider({
	type = "openai",
	url = "http://127.0.0.1:8118",
	key_envar = "",
	max_tokens = 32000,
	reasoning = { effort = "low" },
	temperature = 1,
	top_p = 0.95,
	top_k = 40,
})

local novita = blitz.add_provider({
	type = "openai",
	url = "https://api.novita.ai/openai/v1",
	key_envar = "NOVITA_API_KEY",
	reasoning = { effort = "medium" },
	temperature = 1,
	max_tokens = 32000,
})

local openrouter = blitz.add_provider({
	type = "openai",
	url = "https://openrouter.ai/api/v1",
	key_envar = "OPENROUTER_API_KEY",
	reasoning = { effort = "low" },
	temperature = 1,
	max_tokens = 32000,
})

local openai = blitz.add_provider({
	type = "openai",
	url = "https://api.openai.com/v1",
	key_envar = "OPENAI_API_KEY",
	max_tokens = 32000,
})

-----------------------------------------------------------------------

blitz.set_agent_tools(blitz.AGENT_MAIN, {
	blitz.TOOL_BASH,
	blitz.TOOL_CANCEL_BACKGROUND,
	blitz.TOOL_READ,
	blitz.TOOL_WRITE,
	blitz.TOOL_EDIT,
	-- blitz.TOOL_LIST_TASKS,
	-- blitz.TOOL_UPDATE_TASK_STATE,
	-- blitz.TOOL_CREATE_TASK,
	blitz.TOOL_ASK,
	blitz.TOOL_AGENT,
	-- blitz.TOOL_PATCH,
	"lua_repl",
	"lua_webfetch",
	"lua_web_search",
})

blitz.set_agent_tools(blitz.AGENT_SUB, {
	blitz.TOOL_BASH,
	blitz.TOOL_READ,
	-- blitz.TOOL_LIST_TASKS,
	-- blitz.TOOL_UPDATE_TASK_STATE,
	-- blitz.TOOL_CREATE_TASK,
	"lua_webfetch",
	"lua_web_search",
})

-- local model = "zai-org/glm-5.1"
-- local model = "google/gemma-4-26b-a4b-it";
-- local model = "moonshotai/kimi-k2.6"
-- local model = "minimax/minimax-m2.7"
-- local model = "deepseek/deepseek-v4-pro"
-- local model = "zai-org/glm-4.7-flash"
-- local model = "gpt-5.4-mini"
-- local model = "inclusionai/ling-2.6-1t"
-- local model = "xiaomimimo/mimo-v2.5-pro"
-- local model = "qwen/qwen3.5-397b-a17b"
-- local model = "google/gemma-4-31b-it"

local model = "deepseek/deepseek-v4-flash"
-- local model = "minimax/minimax-m3"
-- local model = "xiaomimimo/mimo-v2.5"
blitz.set_model("max", model, novita)
blitz.set_model("mid", model, novita)
blitz.set_model("min", model, novita)

blitz.bind("<C-b>", function()
	blitz.set_model("max", "deepseek/deepseek-v4-pro", novita)
	blitz.set_model("mid", model, novita)
	blitz.set_model("min", model, novita)
end)

--- GPT mega mode
blitz.bind("<C-o>", function()
	local gpt = "gpt-5.4-mini"
	blitz.set_model("max", gpt, openai)
	blitz.set_model("mid", gpt, openai)
	blitz.set_model("min", gpt, openai)

	blitz.set_agent_tools(blitz.AGENT_MAIN, {
		blitz.TOOL_BASH,
		blitz.TOOL_CANCEL_BACKGROUND,
		blitz.TOOL_READ,
		-- blitz.TOOL_LIST_TASKS,
		-- blitz.TOOL_UPDATE_TASK_STATE,
		-- blitz.TOOL_CREATE_TASK,
		blitz.TOOL_ASK,
		blitz.TOOL_PATCH,
	})
end)

blitz.add_command(":plan", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		effort = "max",
		prompt = "Before making ANY edits, explain your implementation plan to the user and await his go. This is the request: "
			.. rem,
	})
	blitz.queue.push_chat_entry("user", "[PLAN]: " .. rem)
end)

-- Local mode
blitz.bind("<C-l>", function()
	local local_model = "gemma-4-12b-it"
	-- local local_model = "Qwen3.6-35B-A3B"
	blitz.set_model("max", local_model, llama)
	blitz.set_model("mid", local_model, llama)
	blitz.set_model("min", local_model, llama)
	blitz.set_compact_edge(128000)
end)

local function fmt(n)
	local units = { "k", "M", "G" }
	local u = 0
	while n >= 1000 and u < #units do
		n = n / 1000
		u = u + 1
	end
	if u == 0 then
		return tostring(math.floor(n))
	end
	return string.format("%.1f%s", n, units[u])
end

blitz.status_bar_render = function()
	local use = blitz.token_usage()

	return "Cache:"
		.. fmt(use.cache)
		.. " | In:"
		.. fmt(use.input)
		.. " | Out:"
		.. fmt(use.output)
		.. " | Ctx:"
		.. math.floor(blitz.context_percent())
		.. "%"
end

-------------------------------------------------------------------------------------------------
--- Playwright testing mcp

local playmcp = blitz.mcp.add({
	name = "playwright",
	command = "npx",
	args = {
		"-y",
		"@playwright/mcp@latest",
		"--browser=chromium",
		"--executable-path=/usr/bin/chromium",
	},
	tools_prefix = "pw_",
})

local is_active = false

blitz.add_command(":browser", function()
	if is_active == true then
		return
	end

	blitz.queue.push_chat_entry("system", "playwright enabled")
	blitz.mcp.enable(playmcp, blitz.AGENT_MAIN)
	is_active = true
end)

blitz.add_doc("zig std", "zig std lib source code", "/usr/lib/zig/std")
blitz.add_doc("knoedel", "knoedel entity component system (ECS)", "/home/lommix/Projects/zig/knoedel")
blitz.add_doc("lomstd", "lommix extended zig std and util lib", "/home/lommix/Projects/zig/lomstd")

blitz.set_mode_prompt(
	blitz.MODE_RESEARCH,
	[[
    # Research mode active

    you are in READ-ONLY mode. Any file edits, modifications, or system changes are prohibited.
    Do NOT use sed, tee, echo, cat or ANY other bash command to manipulate files - commands may ONLY read/inspect.
    You may only observe, analyze, and research.
    ]]
)

---------------------------------------------------------------------------------------------------
--- CUSTOM MODE TEST
---------------------------------------------------------------------------------------------------
local debug_mode = blitz.add_mode(
	"DEBUG",
	"#AF8F00",
	[[
    # Debug mode active
    You are in debug mode. If you see any Bug or weird behavior in your tool usage or the user prompts immediately stop and inform the user.

    ]],
	"You are in debug mode"
)

blitz.add_command(":save", function()
	blitz.queue.save_session(".blitz/blitz_save.json")
end)

blitz.add_command(":load", function()
	blitz.queue.load_session(".blitz/blitz_save.json")
end)

-------------------------------------------------------------------------------------------------
--- CUSTOM TOOLS
-------------------------------------------------------------------------------------------------

-- example: lua repl tool
blitz.register_tool({
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

blitz.register_tool({
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

		ctx:set_status("(Fetch) " .. url)

		-- headless chromium with virtual-time-budget for SPA rendering
		local handle = io.popen(
			'chromium --headless --disable-gpu --virtual-time-budget=4000 --dump-dom "' .. url .. '" 2>/dev/null'
		)
		if not handle then
			return blitz.err("failed to spawn chromium")
		end

		local html = handle:read("*a")
		local ok = handle:close()

		if not ok or html == nil or html == "" then
			return blitz.err("chromium returned no output")
		end

		ctx:append_log("Converting to markdown...")

		local ok2, markdown = pcall(blitz.html_to_markdown, html)
		if not ok2 or not markdown then
			return blitz.err("failed to convert html to markdown")
		end

		return blitz.ok(markdown)
	end,
})

blitz.register_tool({
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

		ctx:set_status("(SearXNG) " .. query)

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

		local body, ok = ctx:shell("curl -sS --max-time 15 '" .. serach_url .. "'")
		if not ok then
			return blitz.err("searxng request failed (curl exit non-zero)")
		end
		if type(body) ~= "string" or body == "" then
			return blitz.err("searxng returned empty body")
		end

		local val, ok = blitz.json.decode(body)

		if ok == false then
			ctx:append_log("searxng json parse failed: " .. tostring(val))
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
