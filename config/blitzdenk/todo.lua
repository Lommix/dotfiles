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
		colors_cache = {
			ok = fg(theme.ok),
			err = fg(theme.err),
			warn = fg(theme.warn),
			info = fg(theme.info),
			muted = fg(theme.muted),
		}
	end
	return colors_cache
end

local ICON_DONE = "\u{f111}"
local ICON_PENDING = "\u{f10c}"
local ICON_ADD = "\u{f067}"
local ICON_DELETE = "\u{f1f8}"
local ICON_INFO = "\u{f05a}"

local function state_key(agent_id)
	return "todo_" .. agent_id.index .. "_" .. agent_id.generation
end

local function load(agent_id)
	return blitz.state.get(state_key(agent_id)) or {}
end

local function save(agent_id, list)
	blitz.state.set(state_key(agent_id), list)
end

local function next_key(agent_id)
	return state_key(agent_id) .. "_next"
end

local function load_next(agent_id)
	local n = blitz.state.get(next_key(agent_id))
	if n then
		return n
	end
	local max_id = 0
	for _, t in ipairs(load(agent_id)) do
		local i = tonumber(t.id)
		if i and i > max_id then
			max_id = i
		end
	end
	return max_id + 1
end

-------------------------------------------------------------------------------------------------
--- TODO tools
-------------------------------------------------------------------------------------------------
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
		local list = load(ctx.agent_id)
		local nid = load_next(ctx.agent_id)
		list[#list + 1] = {
			id = tostring(nid),
			text = text,
			done = false,
		}
		save(ctx.agent_id, list)
		blitz.state.set(next_key(ctx.agent_id), nid + 1)
		local c = colors()
		ctx:set_status(c.info .. ICON_ADD .. RESET .. " Added #" .. nid .. ": " .. text)
		return { msg = "Added TODO #" .. nid .. ": " .. text }
	end,
})

M.list = blitz.register_tool({
	name = "todo_list",
	description = "List all TODOs with their id, status, and text.",
	args = {},
	func = function(ctx, _)
		local list = load(ctx.agent_id)
		if #list == 0 then
			local c = colors()
			ctx:set_status(c.info .. ICON_INFO .. RESET .. " TODO list is empty")
			return { msg = "TODO list is empty." }
		end
		local c = colors()
		local open, done = 0, 0
		for _, t in ipairs(list) do
			if t.done then
				done = done + 1
			else
				open = open + 1
			end
		end
		local status = {
			(open > 0 and c.warn or c.ok) .. open .. " open" .. RESET .. " \xb7 " .. c.ok .. done .. " done" .. RESET,
		}
		local lines = { "TODO list for agent #" .. ctx.agent_id.index .. ":" }
		for _, t in ipairs(list) do
			local mark = t.done and "\u{f111}" or "\u{f10c}"
			lines[#lines + 1] = string.format("%s #%s %s", mark, t.id, t.text)
			if t.done then
				status[#status + 1] = c.ok .. ICON_DONE .. RESET .. " #" .. t.id .. " " .. c.muted .. t.text .. RESET
			else
				status[#status + 1] = c.ok .. ICON_PENDING .. RESET .. " #" .. t.id .. " " .. t.text
			end
		end
		ctx:set_status(table.concat(status, "\n"))
		return { msg = table.concat(lines, "\n") }
	end,
})

M.update = blitz.register_tool({
	name = "todo_update",
	description = "Update a TODO by id: mark done or delete it. To change text, delete and re-add.",
	args = {
		id = { type = "string", description = "the TODO id", required = true },
		done = { type = "boolean", description = "set true to mark done, false to reopen", required = false },
		delete = { type = "boolean", description = "set true to delete the TODO", required = false },
	},
	func = function(ctx, call)
		local id = tostring(call.arguments.id)
		local args = call.arguments
		if not (args.delete or args.done ~= nil) then
			error("update requires at least one of: done, delete")
		end
		local list = load(ctx.agent_id)
		for i, t in ipairs(list) do
			if t.id == id then
				if args.delete then
					table.remove(list, i)
					save(ctx.agent_id, list)
					local c = colors()
					ctx:set_status(c.warn .. ICON_DELETE .. RESET .. " Deleted #" .. id .. ": " .. t.text)
					return { msg = "Deleted TODO #" .. id .. ": " .. t.text }
				end
				if args.done ~= nil then
					t.done = args.done
				end
				save(ctx.agent_id, list)
				local c = colors()
				local icon = t.done and ICON_DONE or ICON_PENDING
				ctx:set_status(c.ok .. icon .. RESET .. " Updated #" .. id .. ": " .. t.text)
				return { msg = "Updated TODO #" .. id .. ": " .. t.text }
			end
		end
		error("TODO #" .. id .. " not found")
	end,
})

-------------------------------------------------------------------------------------------------
--- Reminder injection: expose pending TODOs in the agent system reminder
-------------------------------------------------------------------------------------------------
blitz.events.add_listener(blitz.events.ON_INJECT, function(agent_id)
	local pending = {}
	for _, t in ipairs(load(agent_id)) do
		if not t.done then
			pending[#pending + 1] = string.format("  - \u{f10c} #%s %s", t.id, t.text)
		end
	end
	if #pending == 0 then
		return nil
	end
	return "Pending TODOs for agent #" .. agent_id.index .. ":\n" .. table.concat(pending, "\n")
end)

return M
