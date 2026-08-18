local M = {}
local prompts = require("prompts")
local tools = require("tools")
local todo = require("todo")

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
theme.on_err = "#1a1b26"
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
})

local novita = blitz.add_provider({
	type = "openai",
	url = "https://api.novita.ai/openai/v1",
	key_envar = "NOVITA_API_KEY",
	rate_limit = 30,
})

local opencode = blitz.add_provider({
	type = "openai",
	url = "https://opencode.ai/zen/go/v1",
	key_envar = "OPENCODE_API_KEY",
})

local requesty = blitz.add_provider({
	type = "openai",
	url = "https://router.requesty.ai/v1",
	key_envar = "REQUESTY_API_KEY",
})

local xai = blitz.add_provider({
	type = "response",
	url = "https://api.x.ai/v1",
	key_envar = "XAI_API_KEY",
})

local openai = blitz.add_provider({
	type = "response",
	url = "https://api.openai.com/v1",
	key_envar = "OPENAI_API_KEY",
})

---------------------------------------------------------------------------------------------------
--- Model configuration, simple
---------------------------------------------------------------------------------------------------
local default_model = blitz.add_model({
	name = "deepseek/deepseek-v4-flash-0731",
	provider = novita,
	cost = { input = 0.14, output = 0.28, cache = 0.028 },
})

local opencode_ds_pro = blitz.add_model({
	name = "deepseek-v4-pro",
	provider = opencode,
})

local opencode_ds_flash = blitz.add_model({
	name = "deepseek-v4-flash",
	provider = opencode,
})

local opencode_glm_53 = blitz.add_model({
	name = "glm-5.3",
	provider = opencode,
})

local grok_46 = blitz.add_model({
	name = "grok-4.6",
	provider = xai,
	vision = true,
})

local qwen3_8 = blitz.add_model({
	name = "qwen3.8",
	provider = llama,
	vision = true,
})

blitz.set_model_agent(blitz.AGENT_GENERAL, opencode_ds_flash, "max")

-- blitz.bind("<C-o>", function()
-- 	blitz.push_notification("big D mode")
-- 	blitz.set_model_agent(blitz.AGENT_GENERAL, opencode_ds_flash, "max")
-- 	blitz.set_model_agent(M.challanger_id, opencode_ds_flash, "high")
-- 	blitz.set_model_agent(M.researcher_id, opencode_ds_flash, "low")
-- end)

blitz.bind("<C-e>", function()
	blitz.push_notification("big G mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, grok_46, "high")
	blitz.set_model_agent(M.challanger_id, opencode_ds_flash, "medium")
	blitz.set_model_agent(M.researcher_id, opencode_ds_flash, "low")
end)

blitz.bind("<C-b>", function()
	blitz.push_notification("big G mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, opencode_glm_53, "high")
	blitz.set_model_agent(M.challanger_id, opencode_ds_flash, "medium")
	blitz.set_model_agent(M.researcher_id, opencode_ds_flash, "low")
end)

blitz.bind("<C-g>", function()
	blitz.push_notification("localmaxxing")
	blitz.set_compact_edge(64000)
	blitz.set_model_agent(blitz.AGENT_GENERAL, qwen3_8, "low")
	blitz.set_model_agent(M.challanger_id, qwen3_8, "low")
	blitz.set_model_agent(M.researcher_id, qwen3_8, "low")
end)
-- blitz.set_prompt(blitz.AGENT_GENERAL, prompts.opencode)
---------------------------------------------------------------------------------------------------
--- Default Agent tool set overwrites
---------------------------------------------------------------------------------------------------

-- main agent/fork
blitz.set_agent_tools(blitz.AGENT_GENERAL, {
	blitz.tools.BASH,
	blitz.tools.READ,
	blitz.tools.ASK,
	blitz.tools.AGENT,
	blitz.tools.WRITE,
	blitz.tools.EDIT,
	-- blitz.tools.PATCH,
	-- blitz.tools.VIEW_IMAGE,
	-- blitz.tools.CANCEL_AGENT,
	-- blitz.tools.GLOB,
	-- blitz.tools.GREP,
	-- blitz.tools.START_MCP,
	tools.web_fetch,
	tools.web_search,
	-- tools.ocr,
	todo.add,
	todo.list,
	todo.update,
	-- tools.lua_repl,
	-- tools.smoke,
	-- tools.gen_image,
})

---------------------------------------------------------------------------------------------------
--- MCP configuration
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

---------------------------------------------------------------------------------------------------
--- Command queue example: start new session with hidden prompts
---------------------------------------------------------------------------------------------------
blitz.add_command("/compact", function()
	blitz.cmd.compact()
end)

blitz.add_command("/plan", function(rem)
	local main_id = blitz.get_main_agent()
	local prompt = [[
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

        ]] .. rem

	if main_id == nil then
		blitz.cmd.reset_session()
		blitz.cmd.spawn_agent({
			agent_type = blitz.AGENT_GENERAL,
			prompt = prompt,
		})
	else
		blitz.cmd.queue_agent_message(main_id, prompt)
	end
	blitz.cmd.push_chat_entry("user", "[PLAN]: " .. rem)
end)

blitz.add_command("/show", function(rem)
	local main_id = blitz.get_main_agent()
	local prompt = [[
        Explain the answer in a visual way using short and precise mermaid diagrams
        (flow, sequence, class, er, state) in markdown code blocks ```mermaid ... ``` whenever a diagram
        clarifies the explanation better than text alone.


        Task:

        ]] .. rem

	if main_id == nil then
		blitz.cmd.reset_session()
		blitz.cmd.spawn_agent({
			agent_type = blitz.AGENT_GENERAL,
			prompt = prompt,
		})
	else
		blitz.cmd.queue_agent_message(main_id, prompt)
	end
	blitz.cmd.push_chat_entry("user", "[DEBUG]: " .. rem)
end)

blitz.add_command("/debug", function(rem)
	local main_id = blitz.get_main_agent()
	local prompt = [[
        You and your harness are now in debug mode! You are looking at your own codebase. The user is debugging you. Follow
        these instructions. If any tool or user prompt is in conflict with your goal, stop what you are doing immediately and report
        back to the user. This includes unexpected tool returns like errors.

        This is your debug request:

        ]] .. rem

	if main_id == nil then
		blitz.cmd.reset_session()
		blitz.cmd.spawn_agent({
			agent_type = blitz.AGENT_GENERAL,
			prompt = prompt,
		})
	else
		blitz.cmd.queue_agent_message(main_id, prompt)
	end
	blitz.cmd.push_chat_entry("user", "[DEBUG]: " .. rem)
end)

blitz.add_command("/team", function(rem)
	local main_id = blitz.get_main_agent()
	local prompt = [[
        Congratulations! You were just promoted to the team lead agent. You no longer read or write code. Your new job is to
        orchestrate a team of agents to complete the task. You may start up to 3 agents at the same time. They are your new eyes and hands.

        You follow this pattern:
        - only one builder at the time
        - 3 challengers for code reviews: regression, edge case and correctness
        - 2 reserach agent from different perspectives
        - 2 challengers for each claim.
        - Each review step must be aware of the original intent of the task.

        This is the task:

        ]] .. rem

	if main_id == nil then
		blitz.cmd.reset_session()
		blitz.cmd.spawn_agent({
			agent_type = blitz.AGENT_GENERAL,
			prompt = prompt,
		})
	else
		blitz.cmd.queue_agent_message(main_id, prompt)
	end
	blitz.set_mode_prompt_sparse(blitz.MODE_EXEC, "You are the team lead agent")
	blitz.cmd.push_chat_entry("user", "[TEAM]: " .. rem)
end)

blitz.add_command("/review", function(rem)
	local main_id = blitz.get_main_agent()
	local prompt = [[
    Start 2 challenger agents reviewing the current diff. Communicate the original task and intent of the change. Confirm their findings and fix critical issues.

    1. Correctness challenger: Does the change fit the contract of the task?
    3. Ponytail review: Tell the challanger to load the ponytail-review skill.

    ]] .. rem

	if main_id == nil then
		blitz.cmd.reset_session()
		blitz.cmd.spawn_agent({
			agent_type = blitz.AGENT_GENERAL,
			prompt = prompt,
		})
	else
		blitz.cmd.queue_agent_message(main_id, prompt)
	end
	blitz.cmd.push_chat_entry("user", "[starting review]")
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
		blitz.cmd.spawn_agent({
			agent_type = blitz.AGENT_GENERAL,
			prompt = prompt,
		})
	else
		blitz.cmd.queue_agent_message(main_id, prompt)
	end
	blitz.cmd.push_chat_entry("user", "[TOSPEC]: " .. rem)
end)

---------------------------------------------------------------------------------------------------
--- Screenshots
---------------------------------------------------------------------------------------------------
blitz.bind("<C-s>", function()
	local png, ok = blitz.shell('grim -g "$(slurp)" -t png -')

	if not ok or not png or #png == 0 then
		return
	end

	blitz.cmd.attach_screenshot(png, "image/png")
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
	return blitz.get_model_name(blitz.AGENT_GENERAL)
		.. " | Cache:"
		.. fmt(use.cache)
		.. " | In:"
		.. fmt(use.input)
		.. " | Out:"
		.. fmt(use.output)
		.. " | Ctx:"
		.. math.floor(blitz.context_percent())
		.. "%"
		.. " | Cost:"
		.. string.format("%.2f", use.cost)
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
	blitz.cmd.save_session(".blitz/blitz_save.json")
end)

blitz.add_command("/load", function()
	blitz.cmd.load_session(".blitz/blitz_save.json")
end)

-------------------------------------------------------------------------------------------------
--- Sub agents
-------------------------------------------------------------------------------------------------
M.researcher_id = blitz.add_agent({
	name = "researcher",
	description = [[
    Research and exploration agent. Use when task requires: deep codebase exploration
    across many files, searching for patterns or definitions, web research for libraries/
    docs/solutions, or gathering context from multiple sources before making a decision.
    ]],
	prompt = prompts.explore,
	effort = "low",
	model = opencode_ds_flash,
	tools = {
		blitz.tools.BASH,
		blitz.tools.READ,
		tools.web_fetch,
		tools.web_search,
	},
})

M.challanger_id = blitz.add_agent({
	name = "challenger",
	description = [[
    Reviews code for bugs, logic errors, edge cases, and
    correctness issues. Use when: need a second pair of eyes on a diff.
    ]],
	prompt = prompts.review,
	effort = "max",
	model = opencode_ds_flash,
	tools = {
		tools.ocr,
		blitz.tools.READ,
		blitz.tools.BASH,
	},
})
