local M = {}
local prompts = require("prompts")
local tools = require("tools")

blitz.set_compact_edge(250000)
local flags = blitz.get_flags()
flags.show_thinking = false
flags.debug_log = true
flags.skip_permissions = true
blitz.set_flags(flags)

local theme = blitz.get_theme()
theme.bg = "#181824"
blitz.set_theme(theme)

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

local requesty = blitz.add_provider({
	type = "openai",
	url = "https://router.requesty.ai/v1",
	key_envar = "REQUESTY_API_KEY",
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
	blitz.tools.CANCEL_PROCESS,
	blitz.tools.READ_PROCESS,
	blitz.tools.READ,
	blitz.tools.WRITE,
	blitz.tools.EDIT,
	-- blitz.tools.VIEW_IMAGE,
	-- blitz.tools.LIST_TODOS,
	-- blitz.tools.UPDATE_TODO_STATE,
	-- blitz.tools.CREATE_TODO,
	blitz.tools.ASK,
	-- blitz.tools.AGENT,
	-- blitz.tools.AWAIT_AGENT,
	-- blitz.tools.CANCEL_AGENT,
	-- blitz.tools.SEND_MESSAGE_TO_AGENT,
	blitz.tools.GLOB,
	blitz.tools.GREP,
	blitz.tools.LOADSKILL,
	blitz.tools.START_LSP,
	blitz.tools.START_MCP,
	tools.web_fetch,
	tools.web_search,
	tools.ocr,
	tools.lua_repl,
})

blitz.set_prompt(blitz.AGENT_GENERAL, prompts.opencode)

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
local default_model = "deepseek/deepseek-v4-flash-0731"

--- Price per 1M tokens
local model_costs = {
	["stepfun/step-3.7-flash"] = { input = 0.2, output = 1.15, cache = 0.04 },
	["deepseek/deepseek-v4-flash-0731"] = { input = 0.14, output = 0.28, cache = 0.028 },
	["deepseek/deepseek-v4-flash"] = { input = 0.14, output = 0.28, cache = 0.028 },
	["deepseek/deepseek-v4-pro"] = { input = 1.6, output = 3.2, cache = 0.135 },
	["moonshotai/kimi-k3"] = { input = 3, output = 15, cache = 0.3 },
	["sference/kimi-k3"] = { input = 2.25, output = 11.25, cache = 0.3 },
	["grok-4.5"] = { input = 2, output = 6, cache = 0.5 },
	["sference/glm-5.2"] = { input = 1.5, output = 4.5, cache = 0.38 },
}

blitz.set_model(default_model, novita)
blitz.set_model_agent(blitz.AGENT_GENERAL, default_model, "max", novita)

-- big money mode
blitz.bind("<C-b>", function()
	blitz.push_notification("big Z mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "sference/glm-5.2", "high", requesty)
end)

blitz.bind("<C-e>", function()
	blitz.push_notification("big Kimi mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "sference/kimi-k3", "high", requesty)
end)

blitz.bind("<C-g>", function()
	blitz.push_notification("big Grok mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "grok-4.5", "high", xai)
	blitz.add_tool(blitz.AGENT_GENERAL, blitz.tools.VIEW_IMAGE)
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
		blitz.tools.GLOB,
		blitz.tools.GREP,
		blitz.tools.READ,
		tools.web_fetch,
		tools.web_search,
	},
})

blitz.add_agent({
	name = "challenger",
	description = [[
    Reviews code for bugs, logic errors, edge cases, and
    correctness issues. Use when: need a second pair of eyes on a diff.
    ]],
	prompt = prompts.review,
	effort = "max",
	model = default_model,
	provider = novita,
	tools = {
		tools.ocr,
		blitz.tools.GLOB,
		blitz.tools.GREP,
		blitz.tools.READ,
		blitz.tools.BASH,
	},
})
