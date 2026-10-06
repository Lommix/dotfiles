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
