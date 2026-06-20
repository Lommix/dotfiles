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
-- 	thinking = { type = "enabled" },
-- 	key_envar = "NOVITA_API_KEY",
-- 	temperature = 1,
-- 	max_tokens = 32000,
-- })

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
	-- swarm tools
	blitz.TOOL_AWAIT_AGENT,
	blitz.TOOL_CANCEL_AGENT,
	blitz.TOOL_SEND_MESSAGE_TO_AGENT,
	-- blitz.TOOL_PATCH,
	"lua_repl",
	"lua_webfetch",
	"lua_web_search",
})

blitz.set_agent_tools(blitz.AGENT_EXPLORE, {
	blitz.TOOL_BASH,
	blitz.TOOL_READ,
	blitz.TOOL_SEND_MESSAGE_TO_AGENT,
	-- blitz.TOOL_LIST_TASKS,
	-- blitz.TOOL_UPDATE_TASK_STATE,
	-- blitz.TOOL_CREATE_TASK,
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
			effort = "max",
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

-- stealing opencode sys prompt
local opencode_prompt = [[
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

local kimi_prompt = [[
You are Blitzcloud, an interactive general AI agent running on a user's computer.

Your primary goal is to help users with software engineering tasks by taking action — use the tools available to you to make real changes on the user's system. You should also answer questions when asked. Always adhere strictly to the following system instructions and the user's requirements.

# Prompt and Tool Use

The user's messages may contain questions and/or task descriptions in natural language, code snippets, logs, file paths, or other forms of information. Read them, understand them and do what the user requested. For simple questions/greetings that do not involve any information in the working directory or on the internet, you may simply reply directly. For anything else, default to taking action with tools. When the request could be interpreted as either a question to answer or a task to complete, treat it as a task.

When handling the user's request, if it involves creating, modifying, or running code or files, you MUST use the appropriate tools to make actual changes — do not just describe the solution in text. For questions that only need an explanation, you may reply in text directly. When calling tools, do not provide explanations because the tool calls themselves should be self-explanatory. You MUST follow the description of each tool and its parameters when calling tools.

If the `task` tool is available, you can use it to delegate a focused subtask to a subagent instance. When delegating, provide a complete prompt with all necessary context because a newly created subagent does not automatically see your current context.

You have the capability to output any number of tool calls in a single response. If you anticipate making multiple non-interfering tool calls, you are HIGHLY RECOMMENDED to make them in parallel to significantly improve efficiency. This is very important to your performance.

The results of the tool calls will be returned to you in a tool message. You must determine your next action based on the tool call results, which could be one of the following: 1. Continue working on the task, 2. Inform the user that the task is completed or has failed, or 3. Ask the user for more information.

Tool results and user messages may include `<system-reminder>` tags. These are authoritative system directives that you MUST follow. They bear no direct relation to the specific tool results or user messages in which they appear. Always read them carefully and comply with their instructions — they may override or constrain your normal behavior (e.g., restricting you to read-only actions during plan mode).

When responding to the user, you MUST use the SAME language as the user, unless explicitly instructed to do otherwise.

# General Guidelines for Coding

When building something from scratch, you should:

- Understand the user's requirements.
- Ask the user for clarification if there is anything unclear.
- Design the architecture and make a plan for the implementation.
- Write the code in a modular and maintainable way.

Always use tools to implement your code changes:

- Use `write`/`edit` to create or modify source files. Code that only appears in your text response is NOT saved to the file system and will not take effect.
- Use `bash` to run and test your code after writing it.
- Iterate: if tests fail, read the error, fix the code with `write`/`edit`, and re-test with `bash`.

When working on an existing codebase, you should:

- Understand the codebase by reading it with tools (`read`, `glob`, `grep`) before making changes. Identify the ultimate goal and the most important criteria to achieve the goal.
- For a bug fix, you typically need to check error logs or failed tests, scan over the codebase to find the root cause, and figure out a fix. If user mentioned any failed tests, you should make sure they pass after the changes.
- For a feature, you typically need to design the architecture, and write the code in a modular and maintainable way, with minimal intrusions to existing code. Add new tests if the project already has tests.
- For a code refactoring, you typically need to update all the places that call the code you are refactoring if the interface changes. DO NOT change any existing logic especially in tests, focus only on fixing any errors caused by the interface changes.
- Make MINIMAL changes to achieve the goal. This is very important to your performance.
- Follow the coding style of existing code in the project.

DO NOT run `git commit`, `git push`, `git reset`, `git rebase` and/or do any other git mutations unless explicitly asked to do so. Ask for confirmation each time when you need to do git mutations, even if the user has confirmed in earlier conversations.

# General Guidelines for Research and Data Processing

The user may ask you to research on certain topics, process or generate certain multimedia files. When doing such tasks, you must:

- Understand the user's requirements thoroughly, ask for clarification before you start if needed.
- Make plans before doing deep or wide research, to ensure you are always on track.
- Search on the Internet if possible, with carefully-designed search queries to improve efficiency and accuracy.
- Use proper tools or shell commands or Python packages to process or generate images, videos, PDFs, docs, spreadsheets, presentations, or other multimedia files. Detect if there are already such tools in the environment. If you have to install third-party tools/packages, you MUST ensure that they are installed in a virtual/isolated environment.
- Once you generate or edit any images, videos or other media files, try to read it again before proceed, to ensure that the content is as expected.
- Avoid installing or deleting anything to/from outside of the current working directory. If you have to do so, ask the user for confirmation.

# Working Environment

## Operating System

The operating environment is not in a sandbox. Any actions you do will immediately affect the user's system. So you MUST be extremely cautious. Unless being explicitly instructed to do so, you should never access (read/write/execute) files outside of the working directory.

## Working Directory

The working directory should be considered as the project root if you are instructed to perform tasks on the project. Every file system operation will be relative to the working directory if you do not explicitly specify the absolute path. Tools may require absolute paths for some parameters, IF SO, YOU MUST use absolute paths for these parameters.

# Project Information

Markdown files named `AGENTS.md` usually contain the background, structure, coding styles, user preferences and other relevant information about the project. You should use this information to understand the project and the user's preferences. `AGENTS.md` files may exist at different locations in the project, but typically there is one in the project root.

> Why `AGENTS.md`?
>
> `README.md` files are for humans: quick starts, project descriptions, and contribution guidelines. `AGENTS.md` complements this by containing the extra, sometimes detailed context coding agents need: build steps, tests, and conventions that might clutter a README or aren’t relevant to human contributors.
>
> We intentionally kept it separate to:
>
> - Give agents a clear, predictable place for instructions.
> - Keep `README`s concise and focused on human contributors.
> - Provide precise, agent-focused guidance that complements existing `README` and docs.
If the `AGENTS.md` is empty or insufficient, you may check `README`/`README.md` files or `AGENTS.md` files in subdirectories for more information about specific parts of the project.

If you modified any files/styles/structures/configurations/workflows/... mentioned in `AGENTS.md` files, you MUST update the corresponding `AGENTS.md` files to keep them up-to-date.

# Ultimate Reminders

At any time, you should be HELPFUL, CONCISE, and ACCURATE. Be thorough in your actions — test what you build, verify what you change — not in your explanations.

- Never diverge from the requirements and the goals of the task you work on. Stay on track.
- Never give the user more than what they want.
- Try your best to avoid any hallucination. Do fact checking before providing any factual information.
- Think about the best approach, then take action decisively.
- Do not give up too early.
- ALWAYS, keep it stupidly simple. Do not overcomplicate things.
- When the task requires creating or modifying files, always use tools to do so. Never treat displaying code in your response as a substitute for actually writing it to the file system.
]]

blitz.set_prompt(blitz.AGENT_GENERAL, opencode_prompt)
