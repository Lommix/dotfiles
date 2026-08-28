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

local zai = blitz.add_provider({
	type = "openai",
	url = "https://api.z.ai/api/coding/paas/v4",
	key_envar = "Z_AI_KEY",
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
	name = "glm-5.3-flash",
	provider = zai,
	vision = true,
})

local opencode_ds_flash = blitz.add_model({
	name = "deepseek-v4-flash-vision-exp",
	provider = opencode,
	vision = true,
})

local glm_flash = blitz.add_model({
	name = "glm-5.3-flash",
	provider = zai,
	vision = true,
})

local glm = blitz.add_model({
	name = "glm-5.3",
	provider = zai,
	vision = true,
})

blitz.set_compact_edge(300000)
blitz.set_model_agent(blitz.AGENT_GENERAL, default_model, "high")

blitz.set_theme({
	bg = "#1f2430",
	overlay_dark = "#171b24",
	overlay = "#242936",
	muted = "#707a8c",
	text = "#cbccc6",
	text_hl = "#d9d7ce",
	ok = "#aad94c",
	info = "#73d0ff",
	warn = "#ffb454",
	err = "#f07178",
	on_err = "#1f2430",
	diff_surface = "#2d3647",
	diff_add = "#aad94c",
	diff_remove = "#f07178",
	role_user = "#73d0ff",
	role_agent = "#d2a6ff",
	role_system = "#95e6cb",
})

blitz.bind("<C-o>", function()
	blitz.push_notification("big D mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, opencode_ds_flash, "high")
	blitz.set_model_agent(M.challanger_id, opencode_ds_flash, "high")
	blitz.set_model_agent(M.researcher_id, opencode_ds_flash, "low")
	blitz.set_model_agent(M.writer_id, opencode_ds_flash, "low")
end)

blitz.bind("<C-e>", function()
	blitz.push_notification("big Z mode")
	blitz.set_model_agent(blitz.AGENT_GENERAL, glm, "high")
	blitz.set_model_agent(M.challanger_id, glm_flash, "medium")
	blitz.set_model_agent(M.researcher_id, glm_flash, "low")
	blitz.set_model_agent(M.writer_id, glm_flash, "medium")
end)

-- blitz.set_prompt(blitz.AGENT_GENERAL, prompts.opencode)
---------------------------------------------------------------------------------------------------
--- Default Agent tool set overwrites
---------------------------------------------------------------------------------------------------

blitz.set_capabilities({
	{ binary = "rg", rule = "Use rg for fast recursive grep searches. Prefer rg over grep." },
	{ binary = "fd", rule = "Use fd for fast file discovery. Prefer fd over find." },
	{ binary = "jq", rule = "Use jq to parse and filter JSON data." },
})

local idle_tool = blitz.register_tool({
	name = "idle",
	description = "End your turn. The next event or sub agent will wake you up.",
	func = function(ctx, _)
		ctx:set_status("Waiting for something to happen")
		blitz.get_main_agent()
		return { exit_loop = true }
	end,
})

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
	-- blitz.tools.START_MCP,
	-- blitz.tools.PATCH,
	-- blitz.tools.GLOB,
	-- blitz.tools.GREP,
	tools.web_fetch,
	tools.web_search,
	todo.add,
	todo.done,
	tools.lua_repl,
	idle_tool,
	-- tools.gen_image,
})

---------------------------------------------------------------------------------------------------
--- MCP configuration
---------------------------------------------------------------------------------------------------
-- blitz.mcp.add({
-- 	name = "playwright",
-- 	command = "npx",
-- 	args = {
-- 		"-y",
-- 		"@playwright/mcp@latest",
-- 		"--browser=chromium",
-- 		"--executable-path=/usr/bin/chromium",
-- 	},
-- 	tools_prefix = "pw_",
-- })

---------------------------------------------------------------------------------------------------
--- Command queue example: start new session with hidden prompts
---------------------------------------------------------------------------------------------------
blitz.add_command("compact", function()
	blitz.cmd.compact()
end, "manual compact")

blitz.add_command("cd", function(path)
	blitz.cmd.cd(path)
end, "cd to dir")

blitz.add_command("clear", function()
	blitz.cmd.reset_session()
end, "clear session")

blitz.add_command("improve", function(rem)
	local prompt = [[
You are in retrospective mode. Your scope is the project-local tool sandbox in ./blitz.lua. Everything else is out of scope.

Process:
1. Load the blitzdenk-lua skill and read the local blitz.lua. Do nothing else until it is loaded.
2. Reconstruct the session history from the chat log. List every tool that was used and rate it: did it help, was it redundant, did it fail or force a workaround?
3. Find friction: shell one-liners typed more than once, lookups done by hand, any pattern that needed two or more calls of the same kind. Each repeated pattern is a candidate for a custom tool.
4. Rate every tool already defined in ./blitz.lua: helped, redundant, failed, or forced a workaround. Skip this step silently when there are none.
5. Improve ./blitz.lua only: fix broken tools, implement accepted candidates, one concern per tool, minimal bodies. Expose each new tool with blitz.add_tool(blitz.AGENT_GENERAL, name).
6. Run `luac -p blitz.lua`. Fix errors before continuing; a broken file keeps the old config active after the hot reload.
7. Wait for the hot reload to register the changed tools, then test each new or fixed tool directly with one real call and realistic arguments. Record pass/fail per tool. If the reload lags, fall back: load the file with dofile in lua_repl, use a stub ctx (ctx.cwd real, ctx:set_status no-op), call the tool functions by hand.

Rules:
- Edit only ./blitz.lua in the cwd.
- An edited tool with no recorded direct test count as unfinished work. Test tools by calling them directly!
- Finish with a report: tool ratings, bash friction found, edits made, direct test results.

Reports:
1. List friction found
2. Changelog


]] .. rem

	blitz.cmd.prompt(prompt)
end, "session retrospective, improve local tools")

blitz.add_command("remember", function(rem)
	local prompt = [[
You are in retrospective mode. Your scope is ./AGENTS.md in the cwd. Everything else is out of scope.

AGENTS.md is a wayfinder file. Hard truths and limits are welcome. Implementation details do not matter unless critical!

Process:
1. Reconstruct the session history from the chat log. Collect every durable fact it revealed: module map, build and test commands, non-obvious behavior, rules the user corrected or had to repeat.
2. Read ./AGENTS.md. Compare it with those facts: find missing entries, stale entries, and lines any competent engineer gets by skimming the code anyway.
3. Update ./AGENTS.md only: add proven missing facts, fix stale ones, drop the obvious.
4. Shape: exactly one # headline at the top, ## heads below, bullets not paragraphs, commands as inline code. It is a guide for exploring the codebase, not its documentation.
5. Run `wc -l AGENTS.md`. Stay under 100 lines; compress first if over.

Rules:
- Edit only ./AGENTS.md in the cwd.
- Every added line needs evidence from this session or the codebase.
- No motivation text, no why-explanations, no empty sections.

Reports:
1. Facts extracted
2. Changelog


]] .. rem

	blitz.cmd.prompt(prompt)
end, "update AGENTS.md")

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
end, "plan mode")

blitz.add_command("show", function(rem)
	local prompt = [[
Explain the answer visually. Pick the one mermaid diagram type that best fits the shape of what you are explaining and render it in a markdown code block ```mermaid ... ```.

Choose the type by the structure of the idea:
- flowchart: steps, decisions, branching logic, pipelines
- sequence: message passing over time between actors or components
- class: object types, fields, methods, and their relationships
- er: entities and their relationships (tables, records, keys)
- state: states and the transitions a thing moves through

Use a diagram only when it clarifies more than text alone. Keep it short and precise: label every edge, drop any node or arrow that carries no meaning, and prefer the smallest diagram that tells the whole story.

Task: ]] .. rem
	blitz.cmd.prompt(prompt)
end, "draw diagram")

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
end, "bug hunt")

blitz.add_command("team", function(rem)
	local prompt = [[
You are the team-lead agent. You do not read or write code yourself — you orchestrate sub-agents.
Start by loading the prompt skill and begin orchestrating the work load.

Rules:
- Only one builder active per code base; researchers and reviewers may run in parallel (up to 8 at the same time)
- Challenger agents must be aware of the original intent of the task and load the ponytail skill.
- Each builder is followed by a challenger. Up to 3 iterations on the builder -> challenger loop. Prefer less, skip minor issues.

Task:
]] .. rem

	blitz.cmd.prompt(prompt)
end, "orchestrate")

blitz.add_command("review", function(rem)
	local prompt = [[
Start 2 challenger agents reviewing the current diff. Communicate the original task and intent of the change. Confirm their findings and fix critical issues.

1. Correctness challenger: Does the change fit the contract of the task?
3. Ponytail review: Tell the challanger to load all ponytail skills for the review.

]] .. rem

	blitz.cmd.prompt(prompt)
end, "diff review")

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
end, "write down plan")

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
		.. " • "
		.. blitz.get_model_effort(blitz.AGENT_GENERAL)
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
		blitz.tools.VIEW_IMAGE,
		blitz.tools.SKILL,
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
	effort = "high",
	model = default_model,
	tools = {
		blitz.tools.VIEW_IMAGE,
		blitz.tools.SKILL,
		blitz.tools.READ,
		blitz.tools.BASH,
	},
})

M.writer_id = blitz.add_agent({
	name = "writer",
	description = [[
    Writes any text a human will read. Reviews existing text for clarity.
    Use for marketing, docs and messages. Do not write code.
    ]],
	prompt = prompts.writer,
	effort = "medium",
	model = default_model,
	tools = {
		blitz.tools.VIEW_IMAGE,
		blitz.tools.SKILL,
		blitz.tools.READ,
		blitz.tools.EDIT,
		blitz.tools.WRITE,
		blitz.tools.BASH,
	},
})
