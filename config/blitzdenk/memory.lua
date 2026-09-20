--- ! Memory tool, runs after each agent turn, compacts new facts into a MEMORY.md file. Experimental

local M = {}

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	return content
end

local function write_file(path, content)
	local f, err = io.open(path, "w")
	if not f then
		error(err)
	end
	f:write(content)
	f:close()
end

M.write_memory = blitz.register_tool({
	name = "write_memory",
	description = "Overwrite the project MEMORY.md with the given content. Write the full file, never a diff.",
	snippet = "write MEMORY.md",
	args = {
		content = { type = "string", description = "the full memory text", required = true },
	},
	func = function(ctx, call)
		local path = ctx.cwd .. "/MEMORY.md"
		write_file(path, call.arguments.content)
		return { msg = "written " .. path }
	end,
})

M.read_memory = blitz.register_tool({
	name = "read_memory",
	description = "Read the project MEMORY.md. Returns the full text, or empty when no memory exists yet.",
	snippet = "read MEMORY.md",
	args = {},
	func = function(ctx, _)
		return { msg = read_file(ctx.cwd .. "/MEMORY.md") or "" }
	end,
})

M.edit_memory = blitz.register_tool({
	name = "edit_memory",
	description = "Replace an exact string in the project MEMORY.md. The old_string must match a unique region unless replace_all is true.",
	snippet = "edit MEMORY.md",
	args = {
		old_string = { type = "string", description = "the exact text to replace", required = true },
		new_string = { type = "string", description = "the replacement text", required = true },
		replace_all = { type = "boolean", description = "replace every occurrence (default false)" },
	},
	func = function(ctx, call)
		local old = call.arguments.old_string
		local new = call.arguments.new_string
		if type(old) ~= "string" or old == "" then
			error("old_string is required")
		end
		if type(new) ~= "string" then
			error("new_string is required")
		end
		if old == new then
			error("old_string and new_string are identical")
		end
		local path = ctx.cwd .. "/MEMORY.md"
		local content = read_file(path)
		if not content then
			error("no MEMORY.md yet, use write_memory to create it")
		end
		local matches = {}
		local pos = 1
		while true do
			local i, j = content:find(old, pos, true)
			if not i then
				break
			end
			matches[#matches + 1] = { i, j }
			pos = j + 1
		end
		if #matches == 0 then
			error("old_string not found in MEMORY.md")
		end
		if #matches > 1 and call.arguments.replace_all ~= true then
			error("old_string matches " .. #matches .. " regions, add more context or set replace_all")
		end
		local parts = {}
		local last = 1
		for _, m in ipairs(matches) do
			parts[#parts + 1] = content:sub(last, m[1] - 1)
			parts[#parts + 1] = new
			last = m[2] + 1
		end
		parts[#parts + 1] = content:sub(last)
		write_file(path, table.concat(parts))
		return { msg = "edited " .. path }
	end,
})

M.get_context = blitz.register_tool({
	name = "get_context",
	description = "Return the project AGENTS.md content. Read it to learn the project scope before you judge a fact.",
	snippet = "read AGENTS.md",
	args = {},
	func = function(ctx, _)
		local content = read_file(ctx.cwd .. "/AGENTS.md")
		if not content then
			return { msg = "no AGENTS.md in " .. ctx.cwd }
		end
		return { msg = content }
	end,
})

M.compressor_id = blitz.add_agent({
	name = "compressor",
	description = "extract durable facts for long term memory",
	prompt = [[
You are the memory compressor. You maintain MEMORY.md, the permanent
knowledge file of the project in your working directory. Future agents
read it when a session starts. Most turns produce nothing worth keeping.
Your main skill is to reject, not to collect.

# Scope

Your working directory is the project root. AGENTS.md there defines the
project and its rules. Call get_context to read it before you judge any
fact, and read_memory to see what is already stored.

A fact about something outside this project is out of scope, however
hard it was to find. A change the agent made to a global config, a
dotfile, another repo, or the Blitzdenk tooling itself is out of scope,
unless this project owns that file. Drop those facts without exception.

# The bar

A fact belongs in memory only when it passes all four tests:
1. In scope. It is about this project, not about the wider machine or
   the user's private setup.
2. Durable. It will still be true and still matter in a month.
3. Hard to get again. A fresh agent would need real work, a long debug
   run, or a question to the user to find it.
4. Not written down. It is not in the code, the docs, AGENTS.md, a skill
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
- Facts about files, config, or tools outside the project root.
- Anything about the user, another project, or the machine at large.

# Procedure

1. Call get_context. Learn the project scope.
2. Call read_memory. Know the current entries before you change them.
3. Read the transcript in the user message. It holds one finished turn
   of a working agent. Tool output often holds the evidence: read the
   tool_result lines.
4. Extract candidates from user messages, agent conclusions, and errors
   that got fixed. Run each candidate through the four tests.
5. Merge:
   - Remove entries the turn contradicted or superseded.
   - Keep valid entries. Tighten wording, never drop a live fact.
   - Add new entries under their section.
6. Apply to MEMORY.md:
   - Use edit_memory for a targeted change to an existing entry.
   - Use write_memory to create the file or to replace the whole file.
   - Never send a diff. Touch no file other than MEMORY.md.
7. No candidate passed the tests? Change nothing and stop.

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
	tools = { M.read_memory, M.write_memory, M.edit_memory, M.get_context },
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
		return "The project has an agent MEMORY.md file, read it"
	end,
})

blitz.hooks.agent_complete(function(ev)
	if ev.id ~= blitz.get_main_agent() then
		return
	end
	local rows = blitz.agent.history_since_checkpoint(ev.id)
	local chunk = {}

	-- skip small context
	if #rows < 8 then
		return
	end

	for i, row in ipairs(rows) do
		chunk[i] = row.role .. ": " .. row.text
	end

	blitz.push_notification("starting mem compression")

	local id = blitz.agent.spawn({
		agent_type = M.compressor_id,
		prompt = table.concat(chunk, "\n"),
		background = true,
		clean = true,
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
