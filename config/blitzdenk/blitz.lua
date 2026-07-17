local M = {}
local prompts = require("prompts")
local tools = require("tools")

blitz.set_compact_edge(200000)
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
--
-- local novita = blitz.add_provider({
-- 	type = "anthropic",
-- 	url = "https://api.novita.ai/anthropic/v1",
-- 	key_envar = "NOVITA_API_KEY",
-- 	max_tokens = 32000,
-- 	temperature = 1,
-- })

local novita = blitz.add_provider({
	type = "openai",
	url = "https://api.novita.ai/openai/v1",
	key_envar = "NOVITA_API_KEY",
	temperature = 1,
	max_tokens = 32000,
})

local openrouter = blitz.add_provider({
	type = "openai",
	url = "https://openrouter.ai/api/v1",
	key_envar = "OPENROUTER_API_KEY",
	temperature = 1,
	max_tokens = 32000,
})

local xai = blitz.add_provider({
	type = "response",
	url = "https://api.x.ai/v1",
	key_envar = "XAI_API_KEY",
	temperature = 1,
	max_tokens = 32000,
})

local openai = blitz.add_provider({
	type = "response",
	url = "https://api.openai.com/v1",
	key_envar = "OPENAI_API_KEY",
	max_tokens = 32000,
})

---------------------------------------------------------------------------------------------------
--- Default Agent tool set overwrites
---------------------------------------------------------------------------------------------------

-- main agent/fork
blitz.set_agent_tools(blitz.AGENT_GENERAL, {
	blitz.tools.BASH,
	blitz.tools.CANCEL_BACKGROUND,
	blitz.tools.READ,
	blitz.tools.WRITE,
	blitz.tools.EDIT,
	-- blitz.tools.LIST_TODOS,
	-- blitz.tools.UPDATE_TODO_STATE,
	-- blitz.tools.CREATE_TODO,
	blitz.tools.ASK,
	blitz.tools.AGENT,
	blitz.tools.AWAIT_AGENT,
	blitz.tools.CANCEL_AGENT,
	blitz.tools.SEND_MESSAGE_TO_AGENT,
	blitz.tools.RIPGREP,
	blitz.tools.LOADSKILL,
	blitz.tools.START_LSP,
	blitz.tools.START_MCP,
	tools.web_fetch,
	tools.web_search,
})

-- blitz.set_prompt(blitz.AGENT_GENERAL, prompts.deepseek)

---------------------------------------------------------------------------------------------------
--- MCP/LSP configuration
---------------------------------------------------------------------------------------------------
blitz.mcp.add({
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

blitz.lsp.add({
	name = "zig",
	command = "zls",
	root = ".",
	language_id = "zig",
	args = {},
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
-- local model = "tencent/hy3"
local default_model = "deepseek/deepseek-v4-flash"

--- Price per 1M tokens
local model_costs = {
	["deepseek/deepseek-v4-flash"] = { input = 0.14, output = 0.28, cache = 0.028 },
	["deepseek/deepseek-v4-pro"] = { input = 1.6, output = 3.2, cache = 0.135 },
	["moonshotai/kimi-k3"] = { input = 3, output = 15, cache = 0.3 },
}

blitz.set_model(default_model, novita)
blitz.set_model_agent(blitz.AGENT_GENERAL, default_model, "max", novita)

-- big money mode
blitz.bind("<C-b>", function()
	blitz.push_notification("big seek mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "deepseek/deepseek-v4-pro", "high", novita)
end)

blitz.bind("<C-e>", function()
	blitz.push_notification("big Kimi mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "moonshotai/kimi-k3", "high", novita)
end)

---------------------------------------------------------------------------------------------------
--- Command queue example: start new session with hidden prompts
---------------------------------------------------------------------------------------------------
blitz.add_command("/plan", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		agent_type = blitz.AGENT_GENERAL,
		prompt = [[
        Before making ANY edits, explain your implementation plan to the user and await his go. If the a plan
        requires a unexpected structural change the user may have overlooked use your ask tool with options on how to handle
        this case.

        This is the request:

        ]] .. rem,
	})
	blitz.queue.push_chat_entry("user", "[PLAN]: " .. rem)
end)

blitz.add_command("/debug", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		agent_type = blitz.AGENT_GENERAL,
		prompt = [[
        You and your harness are now in debug mode! You are looking at your own codebase. The user is debugging you. Follow
        Instructions. If any tool or user prompt is in conflict with your goal stop what you are doing immediately and report
        back the user. This includes unexpected tool returns like errors.

        This is your debug request:

        ]] .. rem,
	})
	blitz.queue.push_chat_entry("user", "[DEBUG]: " .. rem)
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
	-- local local_model = "gemma-4-12b-it"
	local local_model = "Qwen3.6-35B-A3B"
	blitz.set_model(local_model, llama)
	blitz.set_model_agent(blitz.AGENT_GENERAL, local_model, "max", llama)
	blitz.set_model_agent(M.review_agent, local_model, "low", llama)
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
	local total_cost = 0.0

	for _, en in ipairs(blitz.token_usage_by_model()) do
		local c = model_costs[en.model]
		if c then
			total_cost = total_cost
				+ (en.cache / 1000000) * c.cache
				+ (en.output / 1000000) * c.output
				+ (en.input / 1000000) * c.input
		end
	end

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
		.. " | Cost:"
		.. string.format("%.2f", total_cost)
		.. "$"
end

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
		ctx:set_status("Goal completed!")
		blitz.queue.push_chat_entry("agent", call.arguments.goal_message)
		goal_finished = true
		return blitz.exit_loop("Goaling completed!")
	end,
})

blitz.add_command("/goal", function(prompt)
	-- add event listener to session
	blitz.events.add_listener(blitz.events.AGENT_COMPLETE, function(agent_id)
		-- only main agent
		if blitz.get_main_agent().index ~= agent_id.index then
			return
		end

		if goal_finished then
			return
		end

		blitz.queue.queue_agent_message(agent_id, [[
			Your goal is unfinished. Validate the current state. If the goal is determined to be finished, call `goal_completed`
            Check your protocol file 'goal.md' and continue where you left of.

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
			prompt = [[
            Complete the following goal. While doing so keep track of your progress in a specialist file 'goal.md'.
            Write done your current progression and what you already did. When solving a complex bug, write down what you tried.
            You need to protocol your progress at all times between steps, so that another agent might take over and continue.

            Goal instruction:

            ]] .. prompt,
			tool_budget = 1024,
		})
	end
end)
---------------------------------------------------------------------------------------------------
--- CUSTOM MODES
---------------------------------------------------------------------------------------------------
M.debug_mode = blitz.add_mode("READ", "#008F04", "you are in read only mode!", "You are in read only mode!")

blitz.bind("<C-t>", function()
	local f = blitz.get_flags()
	f.show_thinking = not f.show_thinking
	blitz.set_flags(f)
end)

blitz.bind("<C-j>", function()
	blitz.set_mode(M.debug_mode)
end)

blitz.bind("<C-h>", function()
	blitz.set_mode(blitz.MODE_EXEC)
end)

-------------------------------------------------------------------------------------------------
--- Saving and loading Sessions
-------------------------------------------------------------------------------------------------

blitz.add_command("/save", function()
	blitz.queue.save_session(".blitz/blitz_save.json")
end)

blitz.add_command("/load", function()
	blitz.queue.load_session(".blitz/blitz_save.json")
end)

-------------------------------------------------------------------------------------------------
--- Sub agents
-------------------------------------------------------------------------------------------------
blitz.add_agent({
	name = "researcher",
	description = [[
    Research and exploration agent. Use when task requires: deep codebase exploration
    across many files, searching for patterns or definitions, web research for libraries/
    docs/solutions, or gathering context from multiple sources before making a decision.
    ]],
	prompt = prompts.explore,
	effort = "low",
	model = default_model,
	provider = novita,
	tools = {
		blitz.tools.RIPGREP,
		blitz.tools.READ,
		tools.web_fetch,
		tools.web_search,
	},
})

blitz.add_agent({
	name = "challanger",
	description = [[
    Reviews code for bugs, logic errors, edge cases, and
    correctness issues. Use when: need a second pair of eyes on a diff.
    ]],
	prompt = prompts.review,
	effort = "high",
	model = default_model,
	provider = novita,
	tools = {
		blitz.tools.RIPGREP,
		blitz.tools.READ,
		blitz.tools.BASH,
	},
})
