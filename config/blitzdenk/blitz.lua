local M = {}

require("draw")
require("voice")
require("memory")
require("permissions")
require("commands")

local prompts = require("prompts")
local tools = require("tools")
local todo = require("todo")
local models = require("provider")
local agents = require("subagents")

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

---------------------------------------------------------------------------------------------------
--- Model configuration
---------------------------------------------------------------------------------------------------
--- defaults
local default_model = models.glm_flash
blitz.set_compact_edge(300000)
blitz.set_agent_model(blitz.AGENT_GENERAL, default_model)
blitz.set_agent_effort(blitz.AGENT_GENERAL, "high")
blitz.set_prompt(blitz.AGENT_GENERAL, prompts.system)

blitz.bind("<C-l>", function()
	blitz.push_notification("big D mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.ds_flash, true)
	blitz.set_agent_model(M.reviewer_id, models.ds_flash, true)
	blitz.set_agent_model(M.researcher_id, models.ds_flash, true)
	blitz.set_agent_model(M.writer_id, models.ds_flash, true)
end, "Big-D")

blitz.bind("<C-o>", function()
	blitz.push_notification("big Q mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.mimo, true)
	blitz.set_agent_model(M.reviewer_id, models.mimo, true)
	blitz.set_agent_model(M.researcher_id, models.mimo, true)
	blitz.set_agent_model(M.writer_id, models.mimo, true)
end, "Big-Q")

blitz.bind("<C-q>", function()
	blitz.push_notification("big free mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.stealth, true)
	blitz.set_agent_model(M.reviewer_id, models.stealth, true)
	blitz.set_agent_model(M.researcher_id, models.stealth, true)
end, "Big-Z")

blitz.bind("<C-e>", function()
	blitz.push_notification("big Z mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.glm, true)
	blitz.set_agent_model(M.reviewer_id, models.glm, true)
	blitz.set_agent_model(M.researcher_id, models.glm, true)
end, "Big-Z")

blitz.bind("<C-g>", function()
	blitz.push_notification("big M mode")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.qwen_38, true)
	blitz.set_agent_model(M.reviewer_id, models.qwen_38, true)
	blitz.set_agent_model(M.researcher_id, models.qwen_38, true)
	blitz.set_agent_model(M.writer_id, models.qwen_38, true)
end, "Big-X")

---------------------------------------------------------------------------------------------------
--- Usefull cli tools
---------------------------------------------------------------------------------------------------
blitz.set_capabilities({
	{ binary = "rg", rule = "Use rg for fast recursive grep searches. Prefer rg over grep." },
	{ binary = "fd", rule = "Use fd for fast file discovery. Prefer fd over find." },
	{ binary = "jq", rule = "Use jq to parse and filter JSON data." },
})

---------------------------------------------------------------------------------------------------
--- Default Agent tool set overwrites
---------------------------------------------------------------------------------------------------
blitz.set_agent_tools(blitz.AGENT_GENERAL, {
	blitz.tools.BASH,
	blitz.tools.READ,
	blitz.tools.ASK,
	blitz.tools.WRITE,
	blitz.tools.EDIT,
	tools.web_fetch,
	tools.web_search,
	todo.add,
	todo.start,
	todo.done,
	todo.list,
	tools.codemode,
	agents.idle_tool,
	agents.message_tool,
	agents.cancel_tool,
	agents.agent_tool,
})

---------------------------------------------------------------------------------------------------
--- SSH
---------------------------------------------------------------------------------------------------
blitz.bind("<C-s>", function()
	local state = blitz.ssh.get_state()
	if state.active then
		blitz.ssh.disable()
	else
		blitz.ssh.enable()
	end
end, "toggle ssh")

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
	local ssh = blitz.ssh.get_state()
	local use = blitz.token_usage()
	local white = "\27[1;37m"
	local green = "\27[32m"
	local orange = "\27[38;5;208m"
	local red = "\27[31m"
	local reset = "\27[0m"

	local ssh_status = ""
	if ssh.active then
		ssh_status = " (SSH ON)"
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
		header = "Effort",
		question = "Set reasoning effort for the general agent?",
		options = { "low", "medium", "high", "xhigh", "max" },
	}, function(choice)
		if choice then
			blitz.set_agent_effort(blitz.AGENT_GENERAL, choice, true)
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
on code quality. Not for finding bugs in written code; use code-reviewer.
]],
	prompt = prompts.explore,
	effort = "low",
	model = default_model,
	tools = {
		blitz.tools.BASH,
		blitz.tools.READ,
		tools.web_fetch,
		tools.web_search,
		tools.codemode,
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
		tools.codemode,
	},
})

M.writer_id = blitz.add_agent({
	name = "writer",
	description = [[
Writes and edits text a human reads: docs, marketing, website content,
posts, release notes. Not for code review; that is code-reviewer.
]],
	prompt = prompts.writer,
	effort = "medium",
	model = default_model,
	clean = true,
	skills = false,
	tools = {
		blitz.tools.READ,
		blitz.tools.EDIT,
		blitz.tools.WRITE,
		blitz.tools.BASH,
	},
})
