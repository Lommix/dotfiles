local M = {}

blitz.plugin("blitz-core", { path = "/home/lommix/Projects/lua/blitz-core" })
-- blitz.plugin("blitz-core", { url = "https://github.com/Lommix/blitz-core" })
local core = require("blitz-core")

blitz.plugin("blitz-herdr", { path = "/home/lommix/Projects/lua/blitz-herdr" })
-- blitz.plugin("blitz-herdr", { url = "https://github.com/Lommix/blitz-herdr.git" })
local herdr = require("blitz-herdr")
herdr.setup()

require("draw")
require("voice")
require("permissions")
require("commands")

local prompts = require("prompts")
local tools = require("tools")
local models = require("provider")

-- blitz.set_theme({
-- 	bg = "#282c34",
-- 	overlay_dark = "#21252b",
-- 	overlay = "#2c313a",
-- 	border = "#3e4451",
-- 	muted = "#5c6370",
-- 	text = "#abb2bf",
-- 	text_hl = "#d7dae0",
-- 	ok = "#98c379",
-- 	info = "#61afef",
-- 	warn = "#e5c07b",
-- 	err = "#e06c75",
-- 	on_err = "#282c34",
-- 	diff_surface = "#333842",
-- 	diff_add = "#98c379",
-- 	diff_remove = "#e06c75",
-- 	role_user = "#61afef",
-- 	role_agent = "#c678dd",
-- 	role_system = "#56b6c2",
-- })

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
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.ds_new_flash, true)
	blitz.set_agent_model(M.builder_id, models.ds_new_flash, true)
	blitz.set_agent_model(M.reviewer_id, models.ds_new_flash, true)
	blitz.set_agent_model(M.researcher_id, models.ds_new_flash, true)
	blitz.set_agent_model(M.prose_reviewer_id, models.ds_new_flash, true)
	blitz.set_agent_model(M.orchistrator_id, models.ds_new_flash, true)
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
blitz.set_agent_tools(blitz.AGENT_GENERAL, {
	blitz.toolsets.BASH_BACKGROUND,
	-- blitz.tools.BASH,
	blitz.tools.READ,
	blitz.tools.ASK,
	blitz.tools.WRITE,
	blitz.tools.EDIT,
	core.codemode,
	core.subagents.toolset,
	core.todo.toolset,
	tools.web_fetch,
	tools.web_search,
	-- todo.add,
	-- todo.start,
	-- todo.done,
	-- todo.list,
	-- tools.codemode,
	-- agents.idle_tool,
	-- agents.message_tool,
	-- agents.cancel_tool,
	-- agents.agent_tool,
})

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

	local ssh_status = ""

	local prompt_tokens = use.input + use.cache + use.cache_creation
	local hit_percent = 0
	if prompt_tokens > 0 then
		hit_percent = use.cache / prompt_tokens * 100
	end

	local model = blitz.get_model_name(blitz.AGENT_GENERAL)
	local effort = blitz.get_agent_effort(blitz.AGENT_GENERAL)
	local main_id = blitz.get_main_agent()

	if main_id ~= nil then
		model = blitz.agent.get_model(main_id)
		effort = blitz.agent.get_effort(main_id)
	end

	return white
		.. model
		.. " • "
		.. effort
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
		.. " Hit:"
		.. green
		.. string.format("%.1f", hit_percent)
		.. "%"
		.. reset
		.. " Cost:"
		.. red
		.. string.format("$%.2f", use.cost)
		.. orange
		.. ssh_status
end

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
		core.codemode,
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
		core.codemode,
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
