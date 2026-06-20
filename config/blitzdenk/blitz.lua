local prompts = require("prompts")

-- BLITZCLOUD CFG
blitz.set_compact_edge(220000)

local flags = blitz.get_flags()
flags.show_thinking = false
flags.debug_log = true
flags.skip_permissions = true
blitz.set_flags(flags)

---------------------------------------------------------------------------------------------------
--- Provider configuration
---------------------------------------------------------------------------------------------------
local llama = blitz.add_provider({
	type = "openai",
	url = "http://127.0.0.1:8118",
	key_envar = "",
	max_tokens = 32000,
	effort = "max",
	temperature = 1,
})

-- local novita = blitz.add_provider({
-- 	type = "anthropic",
-- 	url = "https://api.novita.ai/anthropic",
-- 	key_envar = "NOVITA_API_KEY",
-- 	effort = "max",
-- 	max_tokens = 32000,
-- 	temperature = 1,
-- })

local novita = blitz.add_provider({
	type = "openai",
	url = "https://api.novita.ai/openai/v1",
	key_envar = "NOVITA_API_KEY",
	effort = "max",
	temperature = 1,
	max_tokens = 32000,
})

local openrouter = blitz.add_provider({
	type = "openai",
	url = "https://openrouter.ai/api/v1",
	key_envar = "OPENROUTER_API_KEY",
	effort = "low",
	temperature = 1,
	max_tokens = 32000,
})

local openai = blitz.add_provider({
	type = "openai",
	url = "https://api.openai.com/v1",
	key_envar = "OPENAI_API_KEY",
})

---------------------------------------------------------------------------------------------------
--- Default Agent tool set overwrites
---------------------------------------------------------------------------------------------------

-- main agent/fork
blitz.set_agent_tools(blitz.AGENT_GENERAL, {
	blitz.TOOL_BASH,
	blitz.TOOL_CANCEL_BACKGROUND,
	blitz.TOOL_READ,
	blitz.TOOL_WRITE,
	blitz.TOOL_EDIT,
	blitz.TOOL_LIST_TASKS,
	blitz.TOOL_UPDATE_TASK_STATE,
	blitz.TOOL_CREATE_TASK,
	blitz.TOOL_ASK,
	blitz.TOOL_AGENT,
	blitz.TOOL_AWAIT_AGENT,
	blitz.TOOL_CANCEL_AGENT,
	blitz.TOOL_SEND_MESSAGE_TO_AGENT,
	"lua_repl",
	"lua_webfetch",
	"lua_web_search",
})

blitz.set_agent_tools(blitz.AGENT_EXPLORE, {
	blitz.TOOL_BASH,
	blitz.TOOL_READ,
	blitz.TOOL_SEND_MESSAGE_TO_AGENT,
	"lua_webfetch",
	"lua_web_search",
})

-- local my_agent_id = blitz.add_new_agent_type({
-- 	name = "fun_explore_agent",
-- 	prompt = "You are funny explorerer",
-- 	model = "deepseek/deepseek-v4-flash",
-- 	default_effort = "low",
-- 	tools = {
-- 		blitz.TOOL_BASH,
-- 		blitz.TOOL_READ,
-- 	},
-- 	in_agent_tool = true,
-- })

---------------------------------------------------------------------------------------------------
--- Model configuration, simple
---------------------------------------------------------------------------------------------------
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
-- local model = "xiaomimimo/mimo-v2.5"

local model = "deepseek/deepseek-v4-flash"

blitz.set_model(model, novita)
blitz.set_model_agent(blitz.AGENT_GENERAL, model, "max", novita)
blitz.set_model_agent(blitz.AGENT_EXPLORE, model, "low", novita)

blitz.add_agent({
	name = "review",
	description = "Review and audit specialist",
	prompt = prompts.review,
	in_agent_tool = true,
	tools = {
		blitz.TOOL_BASH,
		blitz.TOOL_READ,
		blitz.TOOL_SEND_MESSAGE_TO_AGENT,
	},
	model = model,
	provider = novita,
	effort = "max",
})

-- big money mode
blitz.bind("<C-b>", function()
	blitz.set_model_agent(blitz.AGENT_GENERAL, "max", "deepseek/deepseek-v4-pro", novita)
end)

blitz.bind("<C-e>", function()
	blitz.set_model_agent(blitz.AGENT_GENERAL, "max", "zai-org/glm-5.2", novita)
end)

---------------------------------------------------------------------------------------------------
--- Command queue example: start new session with hidden prompts
---------------------------------------------------------------------------------------------------

blitz.add_command(":plan", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		prompt = "Before making ANY edits, explain your implementation plan to the user and await his go. This is the request: "
			.. rem,
	})
	blitz.queue.push_chat_entry("user", "[PLAN]: " .. rem)
end)

---------------------------------------------------------------------------------------------------
--- Screenshots
---------------------------------------------------------------------------------------------------
blitz.bind("<C-s>", function()
	local png, ok = blitz.shell('grim -g "$(slurp)" -t png -')

	if not ok or not png or #png == 0 then
		return
	end

	blitz.queue.attach_screenshot(png, "image/png")
end)

---------------------------------------------------------------------------------------------------
--- keybind for local model
---------------------------------------------------------------------------------------------------

blitz.bind("<C-l>", function()
	local local_model = "gemma-4-12b-it"
	-- local local_model = "Qwen3.6-35B-A3B"
	blitz.set_model(local_model, llama)
	blitz.set_compact_edge(128000)
end)

---------------------------------------------------------------------------------------------------
--- Custom status bar render
---------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------
--- MCP configuration and activating for current session
---------------------------------------------------------------------------------------------------

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

-- session state
local is_active = false

blitz.add_command(":browser", function()
	if is_active == true then
		return
	end

	blitz.push_notification("Playwright MCP enabled!")
	blitz.mcp.enable(playmcp, blitz.AGENT_GENERAL)
	is_active = true
end)

---------------------------------------------------------------------------------------------------
--- Goal mode
---------------------------------------------------------------------------------------------------
local goal_finished = false
local goal_tool = blitz.register_tool({
	name = "goal_completed",
	description = "Only call this tool, when your goal is completed",
	args = {
		goal_message = {
			type = "string",
			description = "Structured goal status report",
			required = true,
		},
	},
	func = function(ctx, call)
		ctx:set_status("Goaling completed!")
		blitz.queue.push_chat_entry("user", call.arguments.goal_message)
		goal_finished = true
		return blitz.exit_loop("Goaling completed!")
	end,
})

blitz.add_command("/goal", function(prompt)
	-- add event listener to session
	blitz.add_listener(blitz.EVENT_AGENT_COMPLETE, function(agent_id)
		-- only main agent
		if blitz.get_main_agent().index ~= agent_id.index then
			return
		end

		if goal_finished then
			return
		end

		blitz.queue.queue_agent_message(agent_id, [[
			Your goal is unfinished. Validate the current state. If the goal is determined to be finished, call `goal_completed`

            Original goal instructions: ]] .. prompt)
	end)

	--- add the tool to the current set
	blitz.add_tool(blitz.AGENT_GENERAL, goal_tool)

	goal_finished = false
	local main_agent_id = blitz.get_main_agent()

	blitz.queue.push_chat_entry("user", "Goal: " .. prompt)

	if main_agent_id ~= nil then
		blitz.queue.queue_agent_message(main_agent_id, "Complete the goal: " .. prompt)
	else
		blitz.queue.spawn_agent({
			prompt = "Complete the goal: " .. prompt,
			tool_budget = 1024,
			level = "write",
		})
	end
end)
---------------------------------------------------------------------------------------------------
--- Doc linking and prompt overwrites
---------------------------------------------------------------------------------------------------
blitz.add_doc("Zig-std", "The searchable zig standard library", "/usr/lib/zig/std")
blitz.add_doc("Knoedel-ECS", "The knoedel entity component system source code", "/home/lommix/Projects/zig/knoedel")
blitz.add_doc("lomstd", "Utility library for zig", "/home/lommix/Projects/zig/knoedel")
---------------------------------------------------------------------------------------------------
--- CUSTOM MODES
---------------------------------------------------------------------------------------------------
local research_mode = blitz.add_mode(
	"RESEARCH",
	"#02A3F0",
	[[
    # Research mode active

    you are in READ-ONLY mode. Any file edits, modifications, or system changes are prohibited.
    Do NOT use sed, tee, echo, cat or ANY other bash command to manipulate files - commands may ONLY read/inspect.
    You may only observe, analyze, and research.

    Your current responsibility is to think, read, search, and delegate explore agents to construct a well formed response.

    ]],
	"You are in research mode. Read Only"
)

local debug_mode = blitz.add_mode(
	"DEBUG",
	"#AF8F04",
	[[
    # Debug instruction mode.

    The creator is debugging you. Be cooperative, transparent, and compliant.
    Explain your reasoning step by step. Report every tool call you make and why.
    Surface any ambiguities, assumptions, or uncertainties.
    If the user asks you to stop, pause, or explain — do it immediately.
    Do not take autonomous action unless explicitly instructed.

    ]],
	"You are in debug instruction mode"
)

local coordinator_mode = blitz.add_mode(
	"SWARM",
	"#aA1F54",
	[[
    # Manager mode
    You MUST NOT do any work yourself. You must delegate sub-agents to parallelize your work. Time is a constraint so parallelism resolve the task faster.
    If sub-agents are running, **wait for them before yielding**, unless the user asks an explicit question.
    If the user asks a question, answer it first, then continue coordinating sub-agents.
    When you ask sub-agent to do the work for you, your only role becomes to coordinate them. Do not perform the actual work while they are working.
    When you have plan with multiple step, process them in parallel by spawning one agent per step when this is possible.
    ]],
	"You are in manager mode, delegate your agents"
)

blitz.bind("<C-z>", function()
	blitz.set_mode(coordinator_mode)
end)

blitz.bind("<C-t>", function()
	local f = blitz.get_flags()
	f.show_thinking = not f.show_thinking
	blitz.set_flags(f)
end)

blitz.bind("<C-j>", function()
	blitz.set_mode(debug_mode)
end)

blitz.bind("<C-h>", function()
	blitz.set_mode(blitz.MODE_EXEC)
end)

-------------------------------------------------------------------------------------------------
--- Saving and loading Sessions
-------------------------------------------------------------------------------------------------

blitz.add_command(":save", function()
	blitz.queue.save_session(".blitz/blitz_save.json")
end)

blitz.add_command(":load", function()
	blitz.queue.load_session(".blitz/blitz_save.json")
end)

-------------------------------------------------------------------------------------------------
--- CUSTOM TOOLS: Lua repl for math
-------------------------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------------------------
--- Web fetch with chromium,
--- without protection
-------------------------------------------------------------------------------------------------
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

		ctx:set_status("fetch " .. url)

		-- headless chromium with virtual-time-budget for SPA rendering.
		-- convert to pdf -> convert pdf to text.
		-- It is not efficient, nor secure, but it works very well and is easy
		local content, ok = blitz.shell(
			"chromium --headless=new --disable-gpu --no-sandbox "
				.. "--disable-blink-features=AutomationControlled "
				.. "--window-size=1920,1080 "
				.. "--virtual-time-budget=5000 "
				.. '--print-to-pdf=/dev/stdout --no-margins "'
				.. url
				.. '" | pdftotext - -'
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

blitz.set_prompt(blitz.AGENT_GENERAL, prompts.opencode)
