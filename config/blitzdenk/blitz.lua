local M = {}

blitz.plugin("blitz-core", { path = "/home/lommix/Projects/lua/blitz-core" })
-- blitz.plugin("blitz-core", { url = "https://github.com/Lommix/blitz-core" })
local core = require("blitz-core")

blitz.plugin("blitz-herdr", { path = "/home/lommix/Projects/lua/blitz-herdr" })
-- blitz.plugin("blitz-herdr", { url = "https://github.com/Lommix/blitz-herdr.git" })
local herdr = require("blitz-herdr")
herdr.setup()

blitz.status_bar_render = core.statusbar

require("draw")
require("voice")
require("permissions")
require("commands")

local prompts = require("prompts")
local tools = require("tools")
local models = require("provider")

---------------------------------------------------------------------------------------------------
--- Model configuration
---------------------------------------------------------------------------------------------------
--- defaults
local default_model = models.glm_flash
blitz.set_read_image_max(1024, 1024)
blitz.set_compact_edge(300000)
blitz.set_agent_model(blitz.AGENT_GENERAL, default_model)
blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
blitz.set_prompt(blitz.AGENT_GENERAL, prompts.system)

local flags = blitz.get_flags()
flags.show_diffs = false
blitz.set_flags(flags)

blitz.bind("<C-l>", function()
	blitz.push_notification("big D mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.ds_flash, true)
	blitz.set_agent_model(M.builder_id, models.ds_flash, true)
	blitz.set_agent_model(M.reviewer_id, models.ds_flash, true)
	blitz.set_agent_model(M.researcher_id, models.ds_flash, true)
	blitz.set_agent_model(M.prose_reviewer_id, models.ds_flash, true)
	blitz.set_agent_model(M.orchistrator_id, models.ds_flash, true)
end, "Big-D")

blitz.bind("<C-o>", function()
	blitz.set_compact_edge(124000)
	blitz.push_notification("big Q mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "high")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.qwen_38, true)
	blitz.set_agent_model(M.builder_id, models.qwen_38, true)
	blitz.set_agent_model(M.reviewer_id, models.qwen_38, true)
	blitz.set_agent_model(M.researcher_id, models.qwen_38, true)
	blitz.set_agent_model(M.prose_reviewer_id, models.qwen_38, true)
end, "Big-Q")

blitz.bind("<C-q>", function()
	blitz.push_notification("big free mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.step, true)
	blitz.set_agent_model(M.builder_id, models.step, true)
	blitz.set_agent_model(M.reviewer_id, models.step, true)
	blitz.set_agent_model(M.researcher_id, models.step, true)
end, "Big-Z")

blitz.bind("<C-e>", function()
	blitz.push_notification("big Z mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.glm, true)
	blitz.set_agent_model(M.builder_id, models.glm, true)
	blitz.set_agent_model(M.reviewer_id, models.glm, true)
	blitz.set_agent_model(M.researcher_id, models.glm, true)
	blitz.set_agent_model(M.prose_reviewer_id, models.glm, true)
end, "Big-Z")

blitz.bind("<C-g>", function()
	blitz.push_notification("big M mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.hy4, true)
	blitz.set_agent_model(M.builder_id, models.hy4, true)
	blitz.set_agent_model(M.reviewer_id, models.hy4, true)
	blitz.set_agent_model(M.researcher_id, models.hy4, true)
	blitz.set_agent_model(M.prose_reviewer_id, models.hy4, true)
	blitz.set_agent_model(M.orchistrator_id, models.hy4, true)
end, "Big-X")

---------------------------------------------------------------------------------------------------
--- Usefull cli tools
---------------------------------------------------------------------------------------------------
blitz.set_capabilities({
	-- { binary = "rg", rule = "Use rg for fast recursive grep searches. rg recurses by default: write `rg -n PATTERN PATH`. The flag `-r` means --replace, so `rg -rn PATTERN` silently prints PATTERN replaced by \"n\" and turns the evidence into garbage. Never pass -r or -R; grep flags do not carry over." },
	{
		binary = "fd",
		rule = "Use fd for fast file discovery. Prefer fd over find. fd hides gitignored files: add -I for runtime data such as local databases.",
	},
	{ binary = "jq", rule = "Use jq to parse and filter JSON data." },
})

---------------------------------------------------------------------------------------------------
--- Default Agent tool set overwrites
---------------------------------------------------------------------------------------------------
local codemode_full = core.codemode.setup({
	name = "codemode",
	tools = {
		-- blitz.tools.BASH,
		-- blitz.tools.READ,
		-- blitz.tools.WRITE,
		-- blitz.tools.EDIT,
	},
	description = "",
	snippet = "",
	guidelines = "",
})
-- 	description = [[Callable tools, each takes one table:
-- - bash{ command, description, timeout? }: run a shell command
-- - read{ file_path, offset?, limit? }: read a text file or image
-- - write{ file_path, content }: write a new file
-- - edit{ file_path, old_string, new_string, replace_all? }: replace text in a file]],
-- })

blitz.set_agent_tools(blitz.AGENT_GENERAL, {
	blitz.toolsets.BASH_BACKGROUND,
	blitz.tools.READ,
	blitz.tools.ASK,
	blitz.tools.WRITE,
	blitz.tools.EDIT,
	-- codemode_full,
	-- core.subagents.toolset,
	-- core.todo.toolset,
	-- tools.web_fetch,
	-- tools.web_search,
})

---------------------------------------------------------------------------------------------------
--- binds
---------------------------------------------------------------------------------------------------
blitz.bind("<C-t>", function()
	local f = blitz.get_flags()
	f.show_thinking = not f.show_thinking
	blitz.set_flags(f)
end, "show thinking")

blitz.add_command("effort", function()
	blitz.cmd.select({
		questions = {
			{
				header = "Effort",
				question = "Set reasoning effort for the general agent?",
				options = { "low", "medium", "high", "xhigh", "max" },
				allow_message = false,
			},
		},
	}, function(answers)
		if answers then
			blitz.set_agent_effort(blitz.AGENT_GENERAL, answers[1][1].text, true)
		end
	end)
end, "set effort level")

-------------------------------------------------------------------------------------------------
--- Sub agent devs
-------------------------------------------------------------------------------------------------
M.researcher_id = blitz.add_agent({
	name = "researcher",
	description = [[
Answers questions by reading code, files, docs, or the web. Locates
definitions, symbols, paths, and patterns; reports facts, never opinions
on code quality. Can search the web. Not for finding bugs in written code; use code-reviewer.
]],
	prompt = prompts.explore,
	effort = "medium",
	model = default_model,
	tools = {
		blitz.tools.BASH,
		blitz.tools.READ,
		tools.web_fetch,
		tools.web_search,
	},
})

M.reviewer_id = blitz.add_agent({
	name = "code-reviewer",
	description = [[
Finds bugs, logic errors, edge cases, and correctness issues in code that
was just written or changed: a diff, a function, a module, or a PR.
Read-only; reports findings, never edits.
]],
	prompt = prompts.review,
	effort = "high",
	model = default_model,
	tools = {
		blitz.tools.READ,
		blitz.tools.BASH,
	},
})

M.builder_id = blitz.add_agent({
	name = "builder",
	description = "Implements one approved slice of a spec inside a fixed write set. No user contact, no subagents.",
	prompt = prompts.builder,
	effort = "high",
	model = default_model,
	tools = {
		blitz.tools.BASH,
		blitz.tools.READ,
		blitz.tools.WRITE,
		blitz.tools.EDIT,
	},
})

M.prose_reviewer_id = blitz.add_agent({
	name = "prose-reviewer",
	description = [[
Finds AI slop, structural tells, and hollow claims in text meant for people:
docs, website copy, posts, emails, READMEs. Reviews English and German.
Read-only; reports findings, never edits. Do not use for conversation or
code review.
]],
	prompt = prompts.prose_review,
	effort = "max",
	model = default_model,
	clean = true,
	skills = false,
	in_agent_tool = false,
	tools = {
		blitz.tools.READ,
		blitz.tools.BASH,
	},
})

M.orchistrator_id = blitz.add_agent({
	name = "lead",
	description = "The team leader will handle big tasks by working his own team of agents.",
	prompt = prompts.orchistrate,
	effort = "max",
	model = models.glm_flash,
	in_agent_tool = false,
	tools = {
		blitz.tools.READ,
		blitz.tools.BASH,
		blitz.tools.WRITE,
		blitz.tools.EDIT,
		blitz.tools.ASK,
		core.subagents.toolset,
	},
})

blitz.add_command("ultramode", function(rem)
	if rem == "" then
		blitz.push_notification("ultramode needs a task")
		return
	end

	local id = blitz.agent.spawn({
		prompt = rem,
		agent_type = M.orchistrator_id,
		task = "Leader",
	})
	if id == nil then
		blitz.cmd.message_timeline("system", "ultramode failed: no free agent slot")
		return
	end

	blitz.cmd.message_timeline("user", "[ULTRAMODE]: " .. rem)
end, "replace the main agent with the team lead")
