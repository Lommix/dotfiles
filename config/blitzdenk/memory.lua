local M = {}

M.write_memory = blitz.register_tool({
	name = "write_memory",
	description = "Overwrite the project MEMORY.md with the given content. Write the full file, never a diff.",
	args = {
		content = { type = "string", description = "the full memory text", required = true },
	},
	func = function(ctx, call)
		local path = ctx.cwd .. "/MEMORY.md"
		local f, err = io.open(path, "w")
		if not f then
			error(err)
		end
		f:write(call.arguments.content)
		f:close()
		return { msg = "written " .. path }
	end,
})

M.read_memory = blitz.register_tool({
	name = "read_memory",
	description = "Read the project MEMORY.md. Returns the full text, or empty when no memory exists yet.",
	args = {},
	func = function(ctx, _)
		local path = ctx.cwd .. "/MEMORY.md"
		local f, err = io.open(path, "r")
		if not f then
			return { msg = "" }
		end
		local content = f:read("*a")
		f:close()
		return { msg = content }
	end,
})

M.compressor_id = blitz.add_agent({
	name = "compressor",
	description = "extract durable facts for long term memory",
	prompt = [[
You are the memory compressor. You maintain MEMORY.md, the permanent
knowledge file of this project. Future agents read it when a session starts.
Most turns produce nothing worth keeping. Your main skill is to reject,
not to collect.

# The bar

A fact belongs in memory only when it passes all three tests:
1. Durable. It will still be true and still matter in a month.
2. Hard to get again. A fresh agent would need real work, a long debug
   run, or a question to the user to find it.
3. Not written down. It is not in the code, the docs, AGENTS.md, a skill
   file, or already in memory.
When one test fails, drop the fact.

# Keep

- User rules that hold beyond the current task: preferences, style
  demands, things to always or never do, review standards.
- Hard-won conclusions: a root cause that took real investigation, a
  non-obvious fix, a workaround an external tool or API forces.
- Environment facts that were discovered, not documented: machine and
  version quirks, required env vars, ports, paths, login steps.
- Project decisions and their reason, when the code alone hides the
  reason.
- Hidden couplings and order constraints: "change X and Y breaks",
  "always rebuild Z after touching W".
- Cases where this turn proved an existing memory entry wrong or stale.

# Reject

- Anything readable from the code, file names, docs, or one grep.
- Progress, plans, TODOs, and other session state.
- Summaries of what was done, unless they end in a durable conclusion.
- One-off and flaky failures that will not recur.
- Knowledge any engineer or model already has.
- Restatements of entries already in memory.
- Guesses, hypotheses, and unverified claims.

# Procedure

1. Call read_memory. Know the current entries before you change them.
2. Read the transcript in the user message. It holds one finished turn
   of a working agent. Tool output often holds the evidence: read the
   tool_result lines.
3. Extract candidates from user messages, agent conclusions, and errors
   that got fixed. Run each candidate through the three tests.
4. Merge:
   - Remove entries the turn contradicted or superseded.
   - Keep valid entries. Tighten wording, never drop a live fact.
   - Add new entries under their section.
5. Call write_memory with the full merged file. Never send a diff.
6. No candidate passed the tests? Change nothing and stop.

# File format

- Markdown. Sections: ## Rules, ## Environment, ## Gotchas, ## Decisions.
  Only create a section that has entries.
- One fact per bullet. Self-contained, imperative, no session
  references. Write "X breaks Y", not "we found X".
- Keep the whole file under 60 lines. When it grows past that, drop the
  least valuable entries first.

Finish with one line: "added N, removed N, kept N".
    ]],
	model = require("provider").ds_flash,
	tools = { M.read_memory, M.write_memory },
	in_agent_tool = false,
})

blitz.hooks.inject({
	main_only = true,
	digest = true,
	func = function()
		local f = io.open("MEMORY.md", "r")
		if not f then
			return nil
		end
		f:close()
		return "The project has MEMORY.md file"
	end,
})

blitz.hooks.agent_complete(function(ev)
	if ev.id ~= blitz.get_main_agent() then
		return
	end
	local compressor = M.compressor_id
	if compressor == 0 then
		blitz.push_notification("memory compressor type missing")
		return
	end
	local rows = blitz.agent.history_since_checkpoint(ev.id)
	local chunk = {}
	for i, row in ipairs(rows) do
		chunk[i] = row.role .. ": " .. row.text
	end

	blitz.push_notification("starting mem compression")

	local id = blitz.agent.spawn({
		agent_type = compressor,
		prompt = table.concat(chunk, "\n"),
		background = true,
		clean = false,
	})

	if id == nil then
		blitz.push_notification("failed to start memory agent")
		return
	end

	if blitz.agent.await(id) == blitz.AWAIT_COMPLETE then
		blitz.push_notification("memory extracted")
	else
		blitz.push_notification("memory extraction failed")
	end
	blitz.agent.close(id)
end)
return M
