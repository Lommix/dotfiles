local M = {}

local RESET = "\x1b[0m"

local colors_cache
local function colors()
	if not colors_cache then
		local theme = blitz.get_theme()
		local function fg(hex)
			hex = hex:gsub("^#", "")
			return string.format(
				"\x1b[38;2;%d;%d;%dm",
				tonumber(hex:sub(1, 2), 16),
				tonumber(hex:sub(3, 4), 16),
				tonumber(hex:sub(5, 6), 16)
			)
		end
		colors_cache = { muted = fg(theme.muted), ok = fg(theme.ok), warn = fg(theme.warn) }
	end
	return colors_cache
end

local STATE_PENDING = "pending"
local STATE_PROGRESS = "in_progress"
local STATE_DONE = "done"

M.marks = {
	[STATE_PENDING] = "[ ]",
	[STATE_PROGRESS] = "[~]",
	[STATE_DONE] = "[x]",
}

local function state_key(agent_id)
	return "todo_" .. agent_id
end

local function load(agent_id)
	return blitz.state.get(state_key(agent_id)) or {}
end

local function save(agent_id, list)
	blitz.state.set(state_key(agent_id), list)
end

local function next_id(agent_id)
	local n = blitz.state.get(state_key(agent_id) .. "_next") or 1
	blitz.state.set(state_key(agent_id) .. "_next", n + 1)
	return n
end

local function find(list, id)
	for i, t in ipairs(list) do
		if t.id == id then
			return i, t
		end
	end
	return nil, nil
end

M.add = blitz.register_tool({
	name = "todo_add",
	description = "Add a task to the TODO list. The new task starts in state pending.",
	args = {
		text = { type = "string", description = "the task description", required = true },
	},
	func = function(ctx, call)
		local text = call.arguments.text
		if type(text) ~= "string" or text == "" then
			error("text is required")
		end
		local nid = next_id(ctx.agent_id)
		local list = load(ctx.agent_id)
		list[#list + 1] = { id = tostring(nid), text = text, state = STATE_PENDING }
		save(ctx.agent_id, list)
		local c = colors()
		ctx:set_status(c.muted .. M.marks[STATE_PENDING] .. RESET .. " new todo `" .. text .. "`")
		return { msg = "added #" .. nid .. " pending: " .. text }
	end,
})

M.start = blitz.register_tool({
	name = "todo_start",
	description = "Start work on a pending TODO. It moves to state in_progress.",
	args = {
		id = { type = "string", description = "the TODO id", required = true },
	},
	func = function(ctx, call)
		local id = tostring(call.arguments.id)
		local list = load(ctx.agent_id)
		local _, todo = find(list, id)
		if not todo then
			error("todo #" .. id .. " not found")
		end
		if todo.state == STATE_DONE then
			error("todo #" .. id .. " is already done")
		end
		local c = colors()
		if todo.state == STATE_PROGRESS then
			ctx:set_status(c.warn .. M.marks[STATE_PROGRESS] .. RESET .. " already in progress `" .. todo.text .. "`")
			return { msg = "already in progress #" .. id .. ": " .. todo.text }
		end
		todo.state = STATE_PROGRESS
		save(ctx.agent_id, list)
		ctx:set_status(c.warn .. M.marks[STATE_PROGRESS] .. RESET .. " started `" .. todo.text .. "`")
		return { msg = "in progress #" .. id .. ": " .. todo.text }
	end,
})

M.done = blitz.register_tool({
	name = "todo_done",
	description = "Finish a TODO by id. It moves to state done and leaves the injected list.",
	args = {
		id = { type = "string", description = "the TODO id", required = true },
	},
	func = function(ctx, call)
		local id = tostring(call.arguments.id)
		local list = load(ctx.agent_id)
		local _, todo = find(list, id)
		if not todo then
			error("todo #" .. id .. " not found")
		end
		local was_done = todo.state == STATE_DONE
		todo.state = STATE_DONE
		save(ctx.agent_id, list)
		local c = colors()
		ctx:set_status(c.ok .. M.marks[STATE_DONE] .. RESET .. " finished `" .. todo.text .. "`")
		if was_done then
			return { msg = "already done #" .. id .. ": " .. todo.text }
		end
		return { msg = "finished #" .. id .. ": " .. todo.text }
	end,
})

function M.inject(agent_id)
	local lines = {}
	for _, t in ipairs(load(agent_id)) do
		if t.state == STATE_PROGRESS then
			lines[#lines + 1] = "  - #id:" .. t.id .. " [in_progress] " .. t.text
		elseif t.state ~= STATE_DONE then
			lines[#lines + 1] = "  - #id:" .. t.id .. " [pending] " .. t.text
		end
	end
	if #lines == 0 then
		return ""
	end
	return "#TODOs:\n" .. table.concat(lines, "\n")
end

blitz.hooks.inject(M.inject)

return M
