local M = {}

---------------------------------------------------------------------------------------------------
--- Subagent communication tools
---------------------------------------------------------------------------------------------------

M.idle_tool = blitz.register_tool({
	name = "idle",
	description = "Use when waiting for your sub agents to finish work",
	snippet = "Wait for your sub agents",
	func = function(ctx, _)
		ctx:set_status("Waiting for something to happen")
		return { exit_loop = true }
	end,
})

M.message_tool = blitz.register_tool({
	name = "message_agent",
	description = "send a message to another agent",
	snippet = "message an agent",
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

M.cancel_tool = blitz.register_tool({
	name = "cancel_agent",
	description = "abort a sub agent",
	snippet = "cancel an agent",
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

M.agent_tool = blitz.register_tool({
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
	snippet = "launch a new agent with a task",
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

		if self_row.depth > 1 then
			error("max agent depth reached")
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
	digest = true,
	func = function(_, agent_type_id)
		if blitz.has_tool(agent_type_id, M.agent_tool) == false then
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

return M
