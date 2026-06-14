-- BLITZCLOUD CFG
blitz.set_compact_edge(200000)

---------------------------------------------------------------------------------------------------
--- Provider configuration
---------------------------------------------------------------------------------------------------
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

-- local novita = blitz.add_provider({
-- 	type = "anthropic",
-- 	url = "https://api.novita.ai/anthropic",
-- 	thinking = { type = "enabled" },
-- 	key_envar = "NOVITA_API_KEY",
-- 	temperature = 1,
-- 	max_tokens = 32000,
-- })

-- local novita = blitz.add_provider({
-- 	type = "anthropic",
-- 	url = "https://api.novita.ai/anthropic",
-- 	key_envar = "NOVITA_API_KEY",
-- 	thinking = { type = "enabled", budget_tokens = 1024 },
-- 	temperature = 0.7,
-- })

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
	reasoning = { effort = "medium" },
	temperature = 1,
	max_tokens = 32000,
})

local openai = blitz.add_provider({
	type = "openai",
	url = "https://api.openai.com/v1",
	key_envar = "OPENAI_API_KEY",
	max_tokens = 32000,
})

---------------------------------------------------------------------------------------------------
--- Default Agent tool set overwrites
---------------------------------------------------------------------------------------------------

-- main agent/fork
blitz.set_agent_tools(blitz.AGENT_MAIN, {
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
	-- blitz.TOOL_PATCH,
	"lua_repl",
	"lua_webfetch",
	"lua_web_search",
})

-- subagents
blitz.set_agent_tools(blitz.AGENT_SUB, {
	blitz.TOOL_BASH,
	blitz.TOOL_READ,
	-- blitz.TOOL_LIST_TASKS,
	-- blitz.TOOL_UPDATE_TASK_STATE,
	-- blitz.TOOL_CREATE_TASK,
	"lua_webfetch",
	"lua_web_search",
})

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
blitz.set_model("max", model, novita)
blitz.set_model("mid", model, novita)
blitz.set_model("min", model, novita)

-- big money mode
blitz.bind("<C-b>", function()
	local m = "deepseek/deepseek-v4-pro"
	blitz.set_model("max", m, novita)
	blitz.set_model("mid", m, novita)
	blitz.set_model("min", m, novita)
end)

blitz.bind("<C-e>", function()
	local m = "moonshotai/kimi-k2.7-code"
	blitz.set_model("max", m, novita)
	blitz.set_model("mid", m, novita)
	blitz.set_model("min", m, novita)
end)

---------------------------------------------------------------------------------------------------
--- GPT config with `patch` tool
---------------------------------------------------------------------------------------------------

blitz.bind("<C-o>", function()
	local gpt = "gpt-5.4-mini"
	blitz.set_model("max", gpt, openai)
	blitz.set_model("mid", gpt, openai)
	blitz.set_model("min", gpt, openai)

	blitz.set_agent_tools(blitz.AGENT_MAIN, {
		blitz.TOOL_BASH,
		blitz.TOOL_CANCEL_BACKGROUND,
		blitz.TOOL_READ,
		blitz.TOOL_LIST_TASKS,
		blitz.TOOL_UPDATE_TASK_STATE,
		blitz.TOOL_CREATE_TASK,
		blitz.TOOL_ASK,
		blitz.TOOL_PATCH,
	})
end)

---------------------------------------------------------------------------------------------------
--- Command queue example: start new session with hidden prompts
---------------------------------------------------------------------------------------------------

blitz.add_command(":plan", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		effort = "max",
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
	blitz.set_model("max", local_model, llama)
	blitz.set_model("mid", local_model, llama)
	blitz.set_model("min", local_model, llama)
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
	blitz.mcp.enable(playmcp, blitz.AGENT_MAIN)
	is_active = true
end)

---------------------------------------------------------------------------------------------------
--- Goal mode
---------------------------------------------------------------------------------------------------
local goal_finished = false
blitz.register_tool({
	name = "goal_completed",
	description = "Only call this tool, when your goal is completed",
	args = {
		goal_message = {
			type = "string",
			description = "the final report after finishing the goal",
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

blitz.add_command("/goal", function(rem)
	-- add event listener to session
	blitz.add_listener(blitz.EVENT_AGENT_COMPLETE, function(agent_id)
		-- only main agent
		if blitz.get_main_agent().index ~= agent_id.index then
			return
		end

		if goal_finished then
			return
		end

		blitz.queue.queue_agent_message(
			agent_id,
			"Your goal is unfinished. Validate the current state. If the goal is determined to be finished, call `goal_completed`"
		)
	end)

	blitz.set_agent_tools(blitz.AGENT_MAIN, {
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
		"lua_repl",
		"lua_webfetch",
		"lua_web_search",
		"goal_completed",
	})

	goal_finished = false
	local main_agent_id = blitz.get_main_agent()
	if main_agent_id ~= nil then
		blitz.queue.queue_agent_message(main_agent_id, "Complete the goal: " .. rem)
	else
		blitz.queue.spawn_agent({ effort = "max", prompt = "Complete the goal: " .. rem })
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

blitz.bind("<C-z>", function()
	blitz.set_mode(research_mode)
end)

local debug_mode = blitz.add_mode(
	"DEBUG",
	"#AF8F04",
	[[
    # You are in debug mode.

    Your goal is to find possible root causes of the user described Bug. When present with multiple possiblities ask the user early for direction.
    Further more. This mode is READ-ONLY. Do not touch code, unless explicitly ordered by the user!

    ]],
	"You are in debug mode"
)

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

		ctx:set_status("(Fetch) " .. url)

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

		local body, ok = blitz.shell("curl -sS --max-time 15 '" .. serach_url .. "'")
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

-- stealing opencode sys prompt
blitz.set_prompt(
	blitz.AGENT_MAIN,
	[[
You are blitzcloud, an interactive CLI tool that helps users with software engineering tasks. Use the instructions below and the tools available to you to assist the user.

IMPORTANT: You must NEVER generate or guess URLs for the user unless you are confident that the URLs are for helping the user with programming. You may use URLs provided by the user in their messages or local files.

# Tone and style
You should be concise, direct, and to the point. When you run a non-trivial bash command, you should explain what the command does and why you are running it, to make sure the user understands what you are doing (this is especially important when you are running a command that will make changes to the user's system).
Remember that your output will be displayed on a command line interface. Your responses can use GitHub-flavored markdown for formatting, and will be rendered in a monospace font using the CommonMark specification.
Output text to communicate with the user; all text you output outside of tool use is displayed to the user. Only use tools to complete tasks. Never use tools like Bash or code comments as means to communicate with the user during the session.
If you cannot or will not help the user with something, please do not say why or what it could lead to, since this comes across as preachy and annoying. Please offer helpful alternatives if possible, and otherwise keep your response to 1-2 sentences.
Only use emojis if the user explicitly requests it. Avoid using emojis in all communication unless asked.
IMPORTANT: You should minimize output tokens as much as possible while maintaining helpfulness, quality, and accuracy. Only address the specific query or task at hand, avoiding tangential information unless absolutely critical for completing the request. If you can answer in 1-3 sentences or a short paragraph, please do.
IMPORTANT: You should NOT answer with unnecessary preamble or postamble (such as explaining your code or summarizing your action), unless the user asks you to.
IMPORTANT: Keep your responses short, since they will be displayed on a command line interface. You MUST answer concisely with fewer than 4 lines (not including tool use or code generation), unless user asks for detail. Answer the user's question directly, without elaboration, explanation, or details. One word answers are best. Avoid introductions, conclusions, and explanations. You MUST avoid text before/after your response, such as "The answer is <answer>.", "Here is the content of the file..." or "Based on the information provided, the answer is..." or "Here is what I will do next...". Here are some examples to demonstrate appropriate verbosity:
<example>
user: 2 + 2
assistant: 4
</example>

<example>
user: what is 2+2?
assistant: 4
</example>

<example>
user: is 11 a prime number?
assistant: Yes
</example>

<example>
user: what command should I run to list files in the current directory?
assistant: ls
</example>

<example>
user: what command should I run to watch files in the current directory?
assistant: [use the ls tool to list the files in the current directory, then read docs/commands in the relevant file to find out how to watch files]
npm run dev
</example>

<example>
user: How many golf balls fit inside a jetta?
assistant: 150000
</example>

<example>
user: what files are in the directory src/?
assistant: [runs ls and sees foo.c, bar.c, baz.c]
user: which file contains the implementation of foo?
assistant: src/foo.c
</example>

<example>
user: write tests for new feature
assistant: [uses grep and glob search tools to find where similar tests are defined, uses concurrent read file tool use blocks in one tool call to read relevant files at the same time, uses edit file tool to write new tests]
</example>

# Proactiveness
You are allowed to be proactive, but only when the user asks you to do something. You should strive to strike a balance between:
1. Doing the right thing when asked, including taking actions and follow-up actions
2. Not surprising the user with actions you take without asking
For example, if the user asks you how to approach something, you should do your best to answer their question first, and not immediately jump into taking actions.
3. Do not add additional code explanation summary unless requested by the user. After working on a file, just stop, rather than providing an explanation of what you did.

# Following conventions
When making changes to files, first understand the file's code conventions. Mimic code style, use existing libraries and utilities, and follow existing patterns.
- NEVER assume that a given library is available, even if it is well known. Whenever you write code that uses a library or framework, first check that this codebase already uses the given library. For example, you might look at neighboring files, or check the package.json (or cargo.toml, and so on depending on the language).
- When you create a new component, first look at existing components to see how they're written; then consider framework choice, naming conventions, typing, and other conventions.
- When you edit a piece of code, first look at the code's surrounding context (especially its imports) to understand the code's choice of frameworks and libraries. Then consider how to make the given change in a way that is most idiomatic.
- Always follow security best practices. Never introduce code that exposes or logs secrets and keys. Never commit secrets or keys to the repository.

# Code style
- IMPORTANT: DO NOT ADD ***ANY*** COMMENTS unless asked

# Doing tasks
The user will primarily request you perform software engineering tasks. This includes solving bugs, adding new functionality, refactoring code, explaining code, and more. For these tasks the following steps are recommended:
- Use the available search tools to understand the codebase and the user's query. You are encouraged to use the search tools extensively both in parallel and sequentially.
- Implement the solution using all tools available to you
- Verify the solution if possible with tests. NEVER assume specific test framework or test script. Check the README or search codebase to determine the testing approach.
- VERY IMPORTANT: When you have completed a task, you MUST run the lint and typecheck commands (e.g. npm run lint, npm run typecheck, ruff, etc.) with Bash if they were provided to you to ensure your code is correct. If you are unable to find the correct command, ask the user for the command to run and if they supply it, proactively suggest writing it to AGENTS.md so that you will know to run it next time.
NEVER commit changes unless the user explicitly asks you to. It is VERY IMPORTANT to only commit when explicitly asked, otherwise the user will feel that you are being too proactive.

- Tool results and user messages may include <system-reminder> tags. <system-reminder> tags contain useful information and reminders. They are NOT part of the user's provided input or the tool result.

# Tool usage policy
- When doing file search, prefer to use the Task tool in order to reduce context usage.
- You have the capability to call multiple tools in a single response. When multiple independent pieces of information are requested, batch your tool calls together for optimal performance. When making multiple bash tool calls, you MUST send a single message with multiple tools calls to run the calls in parallel. For example, if you need to run "git status" and "git diff", send a single message with two tool calls to run the calls in parallel.

You MUST answer concisely with fewer than 4 lines of text (not including tool use or code generation), unless user asks for detail.

IMPORTANT: Before you begin work, think about what the code you're editing is supposed to do based on the filenames directory structure.

# Code References

When referencing specific functions or pieces of code include the pattern `file_path:line_number` to allow the user to easily navigate to the source code location.

<example>
user: Where are errors from the client handled?
assistant: Clients are marked as failed in the `connectToServer` function in src/services/process.ts:712.
</example>

]]
)
