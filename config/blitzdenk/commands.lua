blitz.add_command("yolo", function()
	local flags = blitz.get_flags()
	flags.approval_mode = "yolo"
	blitz.set_flags(flags)
end, "accept all")

blitz.add_command("compact", function()
	blitz.cmd.compact()
end, "manual compact")

blitz.add_command("cd", function(path)
	blitz.cmd.cd(path)
end, "cd to dir")

blitz.add_command("clear", function()
	blitz.cmd.reset_session(true)
end, "clear session")

blitz.bind("<c-x>", function()
	blitz.cmd.reset_session(true)
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

blitz.add_command("selftest", function(rem)
	local prompt = [[
You are in self-test mode. You run inside the Blitzdenk harness, and the harness is the test subject.
Load the blitzdenk-lua skill first; treat ~/.config/blitzdenk/meta.lua as the specification for every
blitz.* call. Your job is to find friction, not to fix anything.

Hunt in three areas:
1. Tools: exercise each tool you own with normal, edge (empty, missing, oversized, unicode), and invalid
   arguments. Flag crashes, misleading errors, silent no-ops, and missing validation.
2. Ambiguity: reread your own system prompt, skills, and tool descriptions. Flag every instruction you
   had to guess at, that contradicts another, or that admits two readings.
3. Friction: note workflows that took a detour, gave no feedback, or made you stop and think.

Rules:
- Evidence only. Show the exact call and its raw output for every finding; never report a suspicion as fact.
- Test through the harness itself (tools, hot reload, agent spawn), not by reading source alone.
- Don't fix anything yet. This is report task

Report one line per finding, worst first, in this shape:
[blocker|papercut|nit] area — expected: X — got: Y — repro: <minimal steps>
Close with counts per severity and the 3 findings worth fixing first. Then use the ask tool to offer:
fix now / write findings to a file / stop.

Your test scope:
]] .. rem

	blitz.cmd.prompt(prompt)
end, "self-test the harness")

blitz.add_command("team", function(rem)
	local prompt = [[
You are the team-lead agent. You do not read or write code yourself — you orchestrate sub-agents.
You can message finished agents to continue the conversation.

Task patterns:
- Feature: research -> plan -> build -> challenge -> report
- Bug: research -> challange -> fix -> challenge -> report
- Research: research -> challenge -> report

Rules:
- Only one builder per domain space at the same time.
- Builders must be informed about other builders currently active.
- Challenger agents must be aware of the original intent of the task.
- Always at least 2 Challengers from different perspective (correctness, edge cases, ponytail).

On prompting sub-agents:
Ensure the sub-agent is focused on the domain of the task. Example sentances to enforce that goal:

> You are a dumb pipe. Do exactly what you are told, literally and narrowly.
> Do not ask questions. Do not explain. Do not infer intent. Do not offer alternatives. Do not add comments, tests,
> abstractions, safeguards, dependencies, cleanup, or formatting. Do not touch unnamed files. Do not fix adjacent
> problems. If blocked, state the exact blocker in one sentence. Return only the requested artifact and one-line verification.
> Every extra word or edit is failure. Be silent, precise, and replaceable.

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
conversation or the codebase — never invent anything to fill a section. Write the file then
report the path and a short summary of what was decided.

]] .. rem

	blitz.cmd.prompt(prompt)
end, "write down plan")

blitz.add_command("what", function()
	local prompt = [[
# Role
You explain a code diff to a tech lead who must approve or reject it. The lead
knows the system but not this branch. Write for a decision, not a tutorial.

# Task

1. Read the diff in full. Read the surrounding code and call sites when a change
   depends on context outside the diff.
2. Group the changes into logical units. Ignore noise (formatting, renames with
   no effect), but state that you ignored it.
3. Explain each unit: what behavior changed, why, and what it touches.
4. State what the diff does NOT do.

# Output format

## Summary
Three sentences maximum. What changes, in plain terms, and the review verdict
you would give (ship / ship with a fix / needs rework).

## Changes
One section per logical unit:
- **What**: the behavior before and after, in one or two sentences.
- **Why**: the reason the change exists.
- **Files**: affected paths.
- **Risk**: what can break, and how likely.

## Decisions worth your attention
Tradeoffs the author made. Alternatives that were rejected. List only real
forks, not style choices.

## Verification
What tests, manual checks, or evidence support this diff. State gaps.

## Open questions
Unresolved items the lead must answer or route. Empty list if none.

# Constraints

- Do not review style, naming, or formatting unless it changes behavior.
- Do not praise. Do not describe the process of reading the diff.
- Do not guess. If the intent is unclear, write "unclear from the diff" and say
  what is missing.
- Never claim a test passes, a bug is fixed, or behavior is safe without
  evidence in the diff or files you read.
- Use the reader's time as the budget. Cut every sentence that does not help
  the lead decide.
- Use short sentences. Active voice. No filler openers.
    ]]
	blitz.cmd.prompt(prompt)
end)
