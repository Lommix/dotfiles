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
