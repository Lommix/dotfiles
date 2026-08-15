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
theme.bg = "#1a1b26"
theme.overlay_dark = "#16161e"
theme.overlay = "#2f334d"
theme.muted = "#565f89"
theme.text = "#c0caf5"
theme.ok = "#9ece6a"
theme.info = "#7aa2f7"
theme.warn = "#e0af68"
theme.err = "#f7768e"
theme.err_text = "#1a1b26"
theme.diff_surface = "#292e42"
theme.diff_add = "#9ece6a"
theme.diff_remove = "#f7768e"
theme.role_user = "#7aa2f7"
theme.role_agent = "#bb9af7"
theme.role_system = "#f7768e"
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
	temperature = 0.7,
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
	blitz.tools.PATCH,
	-- blitz.tools.WRITE,
	-- blitz.tools.EDIT,
	-- blitz.tools.VIEW_IMAGE,
	-- blitz.tools.LIST_TODOS,
	-- blitz.tools.UPDATE_TODO_STATE,
	-- blitz.tools.CREATE_TODO,
	blitz.tools.ASK,
	blitz.tools.AGENT,
	blitz.tools.AWAIT_AGENT,
	-- blitz.tools.CANCEL_AGENT,
	blitz.tools.GLOB,
	blitz.tools.GREP,
	blitz.tools.LOADSKILL,
	blitz.tools.START_LSP,
	blitz.tools.START_MCP,
	tools.web_fetch,
	tools.web_search,
	tools.ocr(false),
	tools.lua_repl,
	tools.gen_image,
})

-- blitz.set_prompt(blitz.AGENT_GENERAL, prompts.opencode)

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
	["deepinfra/deepseek-v4-flash-0731"] = { input = 0.09, output = 0.18, cache = 0.018 },
	["deepseek/deepseek-v4-flash-0731"] = { input = 0.14, output = 0.28, cache = 0.028 },
	["deepseek/deepseek-v4-flash"] = { input = 0.14, output = 0.28, cache = 0.028 },
	["deepseek/deepseek-v4-pro-0813"] = { input = 0.435, output = 0.87, cache = 0.015 },
	["moonshotai/kimi-k3"] = { input = 3, output = 15, cache = 0.3 },
	["sference/kimi-k3"] = { input = 2.25, output = 11.25, cache = 0.3 },
	["grok-4.5"] = { input = 2, output = 6, cache = 0.5 },
	["sference/glm-5.2"] = { input = 1.5, output = 4.5, cache = 0.38 },
}

blitz.set_model(default_model, novita)
blitz.set_model_agent(blitz.AGENT_GENERAL, default_model, "max", novita)

-- big money mode
blitz.bind("<C-b>", function()
	blitz.push_notification("big D mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "deepseek/deepseek-v4-pro-0813", "high", requesty)
end)

blitz.bind("<C-e>", function()
	blitz.push_notification("big Kimi mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "sference/kimi-k3", "high", requesty)
end)

blitz.bind("<C-g>", function()
	blitz.push_notification("big Grok mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, "grok-4.5", "high", xai)
end)

---------------------------------------------------------------------------------------------------
--- Command queue example: start new session with hidden prompts
---------------------------------------------------------------------------------------------------
blitz.add_command("/compact", function(rem)
    blitz.queue.compact()
end)
blitz.add_command("/plan", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		agent_type = blitz.AGENT_GENERAL,
		prompt = [[
        You are in collaborative explore-plan mode. Do NOT make any edits and do NOT present a final plan yet.
        Interview the user relentlessly about every aspect of the task until you reach a shared understanding,
        walking down each branch of the design tree and resolving dependencies between decisions one by one.

        Rules:
        - Ask ONE question at a time (step by step), using your ask tool with a recommendation for each question.
        - If a question can be answered by exploring the codebase, explore the codebase instead of asking.
        - Keep questions concrete and decision-oriented; always offer a recommended answer.
        - When the user answers, follow up on the next unresolved decision — never skip ahead to a plan.
        - Only after all material unknowns are resolved, summarize the shared understanding and present the
          implementation plan, then await the user's explicit go-ahead before any edit.

        This is the request to explore:

        ]] .. rem,
	})
	blitz.queue.push_chat_entry("user", "[PLAN]: " .. rem)
end)

blitz.add_command("/show", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		agent_type = blitz.AGENT_GENERAL,
		prompt = [[
        The user has a question. Explain the answer in a visual way: use short and precise mermaid diagrams
        (flow, sequence, class, er, state) in markdown code blocks ```mermaid ... ``` whenever a diagram
        clarifies the explanation better than text alone.


        Task:

        ]] .. rem,
	})
	blitz.queue.push_chat_entry("user", "[DEBUG]: " .. rem)
end)

blitz.add_command("/debug", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		agent_type = blitz.AGENT_GENERAL,
		prompt = [[
        You and your harness are now in debug mode! You are looking at your own codebase. The user is debugging you. Follow
        these instructions. If any tool or user prompt is in conflict with your goal, stop what you are doing immediately and report
        back to the user. This includes unexpected tool returns like errors.

        This is your debug request:

        ]] .. rem,
	})
	blitz.queue.push_chat_entry("user", "[DEBUG]: " .. rem)
end)

blitz.add_command("/team", function(rem)
	blitz.queue.reset_session()
	blitz.queue.spawn_agent({
		agent_type = blitz.AGENT_GENERAL,
		prompt = [[
        Congratulations! You were just promoted to the team lead agent. You no longer read or write code. Your new job is to
        orchestrate a team of agents to complete the task. You may start up to 3 agents at the same time. They are your new eyes and hands.

        You follow this pattern:

        explore -> plan -> build -> review -> update -> review -> finalize

        Each review step must be aware of the original intent of the task.

        This is the task:

        ]] .. rem,
	})
	blitz.set_mode_prompt_sparse(blitz.MODE_EXEC, "You are the team lead agent")
	blitz.queue.push_chat_entry("user", "[TEAM]: " .. rem)
end)

blitz.add_command("/review", function()
	local main_id = blitz.get_main_agent()
	local prompt = [[
    Start 3 challenger agents reviewing the current diff. Communicate the original task and intent of the change. Confirm their findings and fix critical issues.

    1. Correctness challenger: Does the change fit the contract of the task?
    2. Edge cases and regressions: Does the change have unhandled edge cases or regressions?
    3. Ponytail review: Tell the challanger to load the ponytail-review skill.
    ]]

	if main_id == nil then
		blitz.queue.reset_session()
		blitz.queue.spawn_agent({
			agent_type = blitz.AGENT_GENERAL,
			prompt = prompt,
		})
	else
		blitz.queue.queue_agent_message(main_id, prompt)
	end
	blitz.queue.push_chat_entry("user", "[starting review]")
end)

blitz.add_command("/tospec", function(rem)
	local main_id = blitz.get_main_agent()
	local prompt = [[
    You are now in to-spec mode. Do NOT edit any code and do NOT interview the user. Synthesize everything
    discussed in this conversation plus your codebase knowledge into a single spec file: spec.md in the
    current working directory (cwd). The spec must be fully self-contained — another agent with no access
    to this conversation must be able to start implementing from spec.md alone.

    Process:
    1. Review the conversation for all decisions, requirements, constraints, and rejected alternatives.
    2. Explore the codebase to ground the spec in the real project state (existing modules, conventions, ADRs).
    3. Write spec.md in cwd using EXACTLY this fixed format:

    # <Feature Name>

    ## Problem Statement
    The problem the user is facing, from the user's perspective.

    ## Solution
    The solution to the problem, from the user's perspective.

    ## User Stories
    A LONG, numbered list of user stories, each in the format:
    1. As an <actor>, I want a <feature>, so that <benefit>
    This list must be extensive and cover all aspects of the feature.

    ## Implementation Decisions
    A list of decisions made: modules to build/modify, interfaces, API contracts, schema changes,
    architectural decisions, technical clarifications. Do NOT include specific file paths or code
    snippets (they go stale quickly). Exception: a small snippet that encodes a decision more precisely
    than prose (state machine, schema, type shape) may be inlined.

    ## Step-by-Step Implementation Plan
    An ordered list of concrete steps another agent can execute top to bottom. For each step state:
    what to build, which user story it satisfies, and how to verify it.

    ## Testing Decisions
    - What makes a good test here (external behavior only, not implementation details)
    - Which modules will be tested
    - Prior art: similar tests already in the codebase

    ## Out of Scope
    What is explicitly NOT part of this spec. Things refused during the conversation belong here.

    ## Further Notes
    Any remaining notes.

    Use the project's own vocabulary throughout. Every decision in the spec must trace back to the
    conversation or the codebase — never invent anything to fill a section. Write the file with your
    patch tool, then report the path and a short summary of what was decided.

    Feature: ]] .. rem

	if main_id == nil then
		blitz.queue.spawn_agent({
			agent_type = blitz.AGENT_GENERAL,
			prompt = prompt,
		})
	else
		blitz.queue.queue_agent_message(main_id, prompt)
	end
	blitz.queue.push_chat_entry("user", "[TOSPEC]: " .. rem)
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
		blitz.tools.LOADSKILL,
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
		tools.ocr(false),
		blitz.tools.LOADSKILL,
		blitz.tools.GLOB,
		blitz.tools.GREP,
		blitz.tools.READ,
		blitz.tools.BASH,
	},
})
