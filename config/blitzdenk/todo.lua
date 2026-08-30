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
		colors_cache = { ok = fg(theme.ok), info = fg(theme.info) }
	end
	return colors_cache
end

local ICON_ADD = "\u{f067}"
local ICON_DONE = "\u{f00c}"

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

M.add = blitz.register_tool({
	name = "todo_add",
	description = "Add a task to the TODO list.",
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
		list[#list + 1] = { id = tostring(nid), text = text }
		save(ctx.agent_id, list)
		local c = colors()
		ctx:set_status(c.info .. ICON_ADD .. RESET .. " new todo `" .. text .. "`")
		return { msg = "added #" .. nid .. ": " .. text }
	end,
})

M.done = blitz.register_tool({
	name = "todo_done",
	description = "Finish a TODO by id: it is removed from the list.",
	args = {
		id = { type = "string", description = "the TODO id", required = true },
	},
	func = function(ctx, call)
		local id = tostring(call.arguments.id)
		local list = load(ctx.agent_id)
		for i, t in ipairs(list) do
			if t.id == id then
				table.remove(list, i)
				save(ctx.agent_id, list)
				local c = colors()
				ctx:set_status(c.ok .. ICON_DONE .. RESET .. " finished `" .. t.text .. "`")
				return { msg = "finished #" .. id .. ": " .. t.text }
			end
		end
		error("todo #" .. id .. " not found")
	end,
})

blitz.hooks.inject(function(agent_id)
	local pending = {}
	for _, t in ipairs(load(agent_id)) do
		pending[#pending + 1] = "  - #id:" .. t.id .. " " .. t.text
	end
	if #pending == 0 then
		return nil
	end
	return "#Pending TODOs:\n" .. table.concat(pending, "\n")
end)

return M
