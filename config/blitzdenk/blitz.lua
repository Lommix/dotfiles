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
	blitz.set_agent_model(M.challanger_id, models.ds_flash, true)
	blitz.set_agent_model(M.researcher_id, models.ds_flash, true)
	blitz.set_agent_model(M.writer_id, models.ds_flash, true)
end, "Big-D")

blitz.bind("<C-o>", function()
	blitz.push_notification("big Q mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.mimo, true)
	blitz.set_agent_model(M.challanger_id, models.mimo, true)
	blitz.set_agent_model(M.researcher_id, models.mimo, true)
	blitz.set_agent_model(M.writer_id, models.mimo, true)
end, "Big-Q")

blitz.bind("<C-q>", function()
	blitz.push_notification("big free mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.stealth, true)
	blitz.set_agent_model(M.challanger_id, models.stealth, true)
	blitz.set_agent_model(M.researcher_id, models.stealth, true)
end, "Big-Z")

blitz.bind("<C-e>", function()
	blitz.push_notification("big Z mode")
	blitz.set_agent_effort(blitz.AGENT_GENERAL, "max")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.glm, true)
	blitz.set_agent_model(M.challanger_id, models.glm, true)
	blitz.set_agent_model(M.researcher_id, models.glm, true)
end, "Big-Z")

blitz.bind("<C-g>", function()
	blitz.push_notification("big M mode")
	blitz.set_agent_model(blitz.AGENT_GENERAL, models.qwen_38, true)
	blitz.set_agent_model(M.challanger_id, models.qwen_38, true)
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
--- Subagent communication tools
---------------------------------------------------------------------------------------------------
local idle_tool = blitz.register_tool({
	name = "idle",
	description = "End your turn. The next event or sub agent will wake you up.",
	func = function(ctx, _)
		ctx:set_status("Waiting for something to happen")
		return { exit_loop = true }
	end,
})

local message_tool = blitz.register_tool({
	name = "message_agent",
	description = "send a message to another agent",
	args = {
		agent_id = { type = "integer", description = "the id from the agent tool result", required = true },
		message = { type = "string", description = "the text to deliver", required = true },
	},
	func = function(ctx, call)
		local id = tonumber(call.arguments.agent_id) or error("no agent id provided")
		local msg = tostring(call.arguments.message or error("no message provided"))

		ctx:set_status("To agent(" .. tostring(id) .. ") :\n> \27[38;2;112;122;140m" .. msg .. "\27[0m")
		blitz.agent.message(id, msg)
		return { msg = "send" }
	end,
})

local cancel_tool = blitz.register_tool({
	name = "cancel_agent",
	description = "abort a sub agent",
	args = {
		agent_id = { type = "integer", description = "the id from the agent tool result", required = true },
	},
	func = function(ctx, call)
		local id = tonumber(call.arguments.agent_id) or error("no agent id provided")
		ctx:set_status("Cancel agent(" .. tostring(id) .. ")")
		blitz.agent.cancel(id)
		return { msg = "canceled" }
	end,
})

local agent_tool = blitz.register_tool({
	name = "agent",
	description = [[Launch a new background agent to handle a task autonomously. The tool returns immediately. When the agent finishes, you receive a result file path. Subagents will wake you up]],
	args = {
		description = { type = "string", description = "A short (3-5 word) description of the task", required = true },
		prompt = { type = "string", description = "The task for the agent to perform", required = true },
		agent_type = {
			type = "string",
			description = "The type of specialized agent to use for this task. One name from the available agents catalogue",
			required = true,
		},
		cwd = { type = "string", description = "The working directoy of the agent. Defaults to current" },
		clean = {
			type = "boolean",
			description = "Bare agent: no AGENTS.md context files in the system prompt and no system-reminder injections. Defaults to false",
		},
	},
	snippet = "Launch a subagent",
	guidelines = "Wait for agents by ending your turn",
	func = function(ctx, call)
		local a = call.arguments
		local description = a.description
		local prompt = a.prompt
		local type_name = a.agent_type

		local self_row = nil
		for _, row in ipairs(blitz.list_agents()) do
			if row.agent_id == ctx.agent_id then
				self_row = row
				break
			end
		end
		if self_row == nil then
			error("agent not found")
		end
		if self_row.parent ~= nil then
			error("subagents cannot spawn subagents")
		end
		if type(description) ~= "string" or type(prompt) ~= "string" or type(type_name) ~= "string" then
			error("invalid arguments")
		end
		if a.cwd ~= nil and type(a.cwd) ~= "string" then
			error("invalid arguments")
		end
		if a.clean ~= nil and type(a.clean) ~= "boolean" then
			error("invalid arguments")
		end

		local agent_type_ids = {}
		for _, t in ipairs(blitz.list_agent_types()) do
			agent_type_ids[t.name] = t.agent_type
		end

		local type_id = agent_type_ids[type_name]
		if type_id == nil then
			error("unknown agent type")
		end

		local id = blitz.agent.spawn({
			parent_id = ctx.agent_id,
			prompt = '# Task: "' .. description .. '"\n\n' .. prompt,
			agent_type = type_id,
			cwd = a.cwd,
			background = true,
			task = description,
			clean = a.clean == true,
		})
		if id == nil then
			error("No agent slots left")
		end

		ctx:set_child_id(id)

		local info = "\27[1;38;2;122;162;247m"
		local text = "\27[38;2;192;202;245m"
		local bold = "\27[1m"
		local reset = "\27[0m"
		ctx:set_status(info .. type_name .. reset .. text .. " -> " .. reset .. bold .. description .. reset)

		return { msg = string.format("Agent started in background. agent_id: %d", id) }
	end,
})

---------------------------------------------------------------------------------------------------
--- inject an agent catalogue into new sessions
---------------------------------------------------------------------------------------------------
blitz.hooks.inject({
	main_only = true,
	digest = true,
	func = function(_, agent_type_id)
		if blitz.has_tool(agent_type_id, agent_tool) == false then
			return ""
		end

		local rows = {}
		for _, t in ipairs(blitz.list_agent_types()) do
			if t.in_agent_tool then
				rows[#rows + 1] = "- `" .. t.name .. "`: " .. t.description
			end
		end
		local body = table.concat(rows, "\n")
		if body == "" then
			return ""
		end
		return "<available_agents>\n" .. body .. "\n</available_agents>\n"
	end,
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
	idle_tool,
	message_tool,
	cancel_tool,
	agent_tool,
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
--- Sub agents
-------------------------------------------------------------------------------------------------
M.researcher_id = blitz.add_agent({
	name = "researcher",
	description = [[
    Read-only research and exploration agent. Usefull for locating a definition or pattern across many files,
    looking up exact symbols or paths, or gathering facts from several places, including web search.
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
		blitz.tools.READ,
		blitz.tools.BASH,
		tools.codemode,
	},
})

M.writer_id = blitz.add_agent({
	name = "writer",
	description = [[
    Writes any text a human will read. Reviews existing text for clarity.
    Use for marketing, docs and website content.
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
