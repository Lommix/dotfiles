local M = {}
local prompts = require("prompts")
local tools = require("tools")
local todo = require("todo")
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

local router = blitz.add_provider({
	type = "openai",
	url = "https://openrouter.ai/api/v1",
	key_envar = "OPENROUTER_API_KEY",
})

local hetzner = blitz.add_provider({
	type = "openai",
	url = "https://inference.hetzner.com/api/v1",
	key_envar = "HETZNER_AI_KEY",
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
local default_model = blitz.add_model({
	-- name = "deepseek-v4-flash-vision-exp",
	name = "ox-alpha-free",
	vision = true,
	provider = opencode,
})

local opencode_ds_pro = blitz.add_model({
	name = "deepseek-v4-pro",
	provider = opencode,
})

local opencode_ds_flash = blitz.add_model({
	name = "deepseek-v4-flash-vision-exp",
	provider = opencode,
	vision = true,
})

local opencode_glm_53 = blitz.add_model({
	name = "glm-5.3",
	provider = opencode,
})

local grok_46 = blitz.add_model({
	name = "grok-4.6",
	provider = xai,
	vision = true,
	cost = { input = 2, output = 6, cache = 0.5 },
})

local qwen3_8 = blitz.add_model({
	name = "qwen3.8",
	provider = llama,
	vision = true,
})

blitz.set_compact_edge(128000)
blitz.set_model_agent(blitz.AGENT_GENERAL, default_model, "max")

blitz.bind("<C-o>", function()
	blitz.push_notification("big D mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, opencode_ds_flash, "low")
	blitz.set_model_agent(M.challanger_id, opencode_ds_flash, "high")
	blitz.set_model_agent(M.researcher_id, opencode_ds_flash, "low")
end)
--
-- blitz.bind("<C-e>", function()
-- 	blitz.push_notification("big DP mode")
-- 	blitz.set_model_agent(blitz.AGENT_GENERAL, opencode_ds_pro, "high")
-- 	blitz.set_model_agent(M.challanger_id, opencode_ds_flash, "medium")
-- 	blitz.set_model_agent(M.researcher_id, opencode_ds_flash, "low")
-- end)
--
blitz.bind("<C-b>", function()
	blitz.push_notification("big G mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, opencode_glm_53, "high")
	blitz.set_model_agent(M.challanger_id, opencode_ds_flash, "medium")
	blitz.set_model_agent(M.researcher_id, opencode_ds_flash, "low")
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
	blitz.tools.SKILL,
	blitz.tools.VIEW_IMAGE,
	-- blitz.tools.PATCH,
	-- blitz.tools.GLOB,
	-- blitz.tools.GREP,
	-- blitz.tools.START_MCP,
	tools.web_fetch,
	tools.web_search,
	todo.add,
	todo.list,
	todo.update,
	tools.lua_repl,
	-- tools.ocr,
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
blitz.add_command("compact", function()
	blitz.cmd.compact()
end)

blitz.add_command("cd", function(path)
	blitz.cmd.cd(path)
end)

blitz.add_command("clear", function()
	blitz.cmd.reset_session()
end)

blitz.add_command("help", function(rem)
	blitz.cmd.prompt("Load the blitzdenk skill and help the user: \n" .. rem)
end)

blitz.add_command("plan", function(rem)
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

	blitz.cmd.prompt(prompt)
end)

blitz.add_command("show", function(rem)
	local prompt = [[
Explain the answer in a visual way using short and precise mermaid diagrams
(flow, sequence, class, er, state) in markdown code blocks ```mermaid ... ``` whenever a diagram
clarifies the explanation better than text alone.

Task: ]] .. rem
	blitz.cmd.prompt(prompt)
end)

blitz.add_command("bug", function(rem)
	local prompt = [[
You are in bug hunting mode. Investigate the problem with evidence, not guesses.

Process:
1. Load relevant skills first (e.g. zig, challenger, ponytail) before reading any code.
2. Research the code around the problem: reproduce it if you can, trace the call path, and pin down the root cause.
3. If the bug is obvious and confirmed, report it immediately — do not waste time.
4. Collect several claims or suspicions, then have each confirmed by a challenger agent spawned via your AGENT tool before treating it as fact.
5. Present your findings: root cause, evidence, and a concrete fix proposal.

Finish by invoking the ask tool with possible options on how to proceed.

The bug:

]] .. rem

	blitz.cmd.prompt(prompt)
end)

blitz.add_command("team", function(rem)
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

	blitz.cmd.prompt(prompt)
end)

blitz.add_command("review", function(rem)
	local prompt = [[
Start 2 challenger agents reviewing the current diff. Communicate the original task and intent of the change. Confirm their findings and fix critical issues.

1. Correctness challenger: Does the change fit the contract of the task?
3. Ponytail review: Tell the challanger to load all ponytail skills for the review.

]] .. rem

	blitz.cmd.prompt(prompt)
end)

blitz.add_command("tospec", function(rem)
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

Feature:
]] .. rem

	blitz.cmd.prompt(prompt)
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
	local white = "\27[1;37m"
	local green = "\27[32m"
	local orange = "\27[38;5;208m"
	local red = "\27[31m"
	local reset = "\27[0m"
	return white
		.. blitz.get_model_name(blitz.AGENT_GENERAL)
		.. reset
		.. " (Cache:"
		.. green
		.. fmt(use.cache)
		.. reset
		.. " In:"
		.. orange
		.. fmt(use.input)
		.. reset
		.. " Out:"
		.. orange
		.. fmt(use.output)
		.. reset
		.. ") Ctx:"
		.. white
		.. math.floor(blitz.context_percent())
		.. "%"
		.. reset
		.. " Cost:"
		.. red
		.. string.format("$%.2f", use.cost)
		.. reset
end

---------------------------------------------------------------------------------------------------
--- Thinking
---------------------------------------------------------------------------------------------------
blitz.bind("<C-t>", function()
	local f = blitz.get_flags()
	f.show_thinking = not f.show_thinking
	blitz.set_flags(f)
end)

-------------------------------------------------------------------------------------------------
--- Saving and loading Sessions
-------------------------------------------------------------------------------------------------

blitz.add_command("save", function()
	blitz.cmd.save_session(".blitz/blitz_save.json")
end)

blitz.add_command("load", function()
	blitz.cmd.load_session(".blitz/blitz_save.json")
end)

-------------------------------------------------------------------------------------------------
--- Sub agents
-------------------------------------------------------------------------------------------------
M.researcher_id = blitz.add_agent({
	name = "researcher",
	description = [[
    Read-only research and exploration agent. Delegate when the task needs search you
    would grind through yourself: locating a definition or pattern across many files,
    picking a library or API from docs, looking up exact symbols or paths, or gathering
    facts from several places. Always prefer this subagent for pure lookup work instead of
    exploring from the main loop. Does not edit, build, or test.
    ]],
	prompt = prompts.explore,
	effort = "low",
	model = default_model,
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
	model = default_model,
	tools = {
		tools.ocr,
		blitz.tools.READ,
		blitz.tools.BASH,
	},
})
