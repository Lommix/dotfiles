local M = {}
local prompts = require("prompts")
local tools = require("tools")

blitz.set_compact_edge(220000)

local flags = blitz.get_flags()
flags.show_thinking = false
flags.debug_log = true
flags.skip_permissions = true
blitz.set_flags(flags)

---------------------------------------------------------------------------------------------------
--- Provider configuration
---------------------------------------------------------------------------------------------------
-- local llama = blitz.add_provider({
-- 	type = "openai",
-- 	url = "http://127.0.0.1:8118",
-- 	key_envar = "",
-- 	max_tokens = 32000,
-- 	effort = "max",
-- 	temperature = 1,
-- })
--
-- local novita = blitz.add_provider({
-- 	type = "anthropic",
-- 	url = "https://api.novita.ai/anthropic",
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

-- local openrouter = blitz.add_provider({
-- 	type = "openai",
-- 	url = "https://openrouter.ai/api/v1",
-- 	key_envar = "OPENROUTER_API_KEY",
-- 	temperature = 1,
-- 	max_tokens = 32000,
-- })
--
-- local openai = blitz.add_provider({
-- 	type = "openai",
-- 	url = "https://api.openai.com/v1",
-- 	key_envar = "OPENAI_API_KEY",
-- })

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
	-- blitz.tools.LIST_TASKS,
	-- blitz.tools.UPDATE_TASK_STATE,
	-- blitz.tools.CREATE_TASK,
	blitz.tools.ASK,
	blitz.tools.AGENT,
	blitz.tools.AWAIT_AGENT,
	blitz.tools.CANCEL_AGENT,
	blitz.tools.SEND_MESSAGE_TO_AGENT,
	blitz.tools.RIPGREP,
	blitz.tools.LOADSKILL,
	blitz.tools.START_LSP,
	blitz.tools.START_MCP,
	-- tools.web_fetch,
	-- tools.web_search,
})

blitz.set_agent_tools(blitz.AGENT_EXPLORE, {
	blitz.tools.RIPGREP,
	blitz.tools.READ,
	blitz.tools.SEND_MESSAGE_TO_AGENT,
	blitz.tools.LOADSKILL,
	tools.web_fetch,
	tools.web_search,
})

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

local model = "deepseek/deepseek-v4-flash"

blitz.set_model(model, novita)
blitz.set_model_agent(blitz.AGENT_GENERAL, model, "max", novita)
blitz.set_model_agent(blitz.AGENT_EXPLORE, model, "low", novita)

M.review_agent = blitz.add_agent({
	name = "review",
	description = "Review and audit specialist",
	prompt = prompts.review,
	in_agent_tool = true,
	tools = {
		blitz.tools.BASH,
		blitz.tools.READ,
		blitz.tools.SEND_MESSAGE_TO_AGENT,
	},
	model = model,
	provider = novita,
	effort = "max",
})

-- big money mode
blitz.bind("<C-b>", function()
	blitz.push_notification("big mode deepseek")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "deepseek/deepseek-v4-pro", "high", novita)
end)

blitz.bind("<C-e>", function()
	blitz.push_notification("big mode Z")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "zai-org/glm-5.2", "high", novita)
end)

---------------------------------------------------------------------------------------------------
--- Command queue example: start new session with hidden prompts
---------------------------------------------------------------------------------------------------
blitz.add_command(":plan", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		agent_type = blitz.AGENT_GENERAL,
		prompt = [[
        Before making ANY edits, explain your implementation plan to the user and await his go. If the a plan
        requires a unvorseen structural change the user may have overlooked use your ask tool with options on how to handle
        this case.
        This is the request: "
        ]] .. rem,
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
	-- local local_model = "gemma-4-12b-it"
	local local_model = "Qwen3.6-35B-A3B"
	blitz.set_model(local_model, llama)
	blitz.set_model_agent(blitz.AGENT_GENERAL, local_model, "max", llama)
	blitz.set_model_agent(blitz.AGENT_EXPLORE, local_model, "low", llama)
	blitz.set_model_agent(M.swarm_agent, local_model, "low", llama)
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
--- Swarm mode
---------------------------------------------------------------------------------------------------
-- no tools, only sub agents

M.swarm_agent = blitz.add_agent({
	name = "swarm",
	description = "mega swarm mode",
	prompt = prompts.swarm_prompt,
	in_agent_tool = false,
	tools = {
		blitz.tools.AGENT,
		blitz.tools.AWAIT_AGENT,
		blitz.tools.SEND_MESSAGE_TO_AGENT,
	},
	model = model,
	provider = novita,
	effort = "max",
})

blitz.add_command("/swarm", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		agent_type = M.swarm_agent,
		prompt = rem,
	})
	blitz.queue.push_chat_entry("user", rem)
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
		ctx:set_status("Goal completed!")
		blitz.queue.push_chat_entry("agent", call.arguments.goal_message)
		goal_finished = true
		return blitz.exit_loop("Goaling completed!")
	end,
})

--- EVENT TEST
blitz.events.add_listener(blitz.events.AGENT_STARTED, function(args)
	-- blitz.queue.queue_agent_message(args, "Load in your ponytail skill so tolve the request")
	blitz.push_notification("new agent started " .. tostring(args.index))
end)

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
            You need to protocol your progress at all times, so that another user might take over and continue.

            After any change immediately update your progress. Step by step!

            Goal instruction:

            ]] .. prompt,
			tool_budget = 1024,
		})
	end
end)
---------------------------------------------------------------------------------------------------
--- CUSTOM MODES
---------------------------------------------------------------------------------------------------
M.debug_mode = blitz.add_mode("READ", "#008F04", "READ ONLY MODE! DO NOT MAKE ANY EDITS", "READ ONLY MODE!")

blitz.bind("<C-t>", function()
	local f = blitz.get_flags()
	f.show_thinking = not f.show_thinking
	blitz.set_flags(f)
end)

blitz.bind("<C-j>", function()
	blitz.set_mode(M.debug_mode)
	-- local r = blitz.tools.remove("test that")
	-- blitz.push_notification(r or "nothing")
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
