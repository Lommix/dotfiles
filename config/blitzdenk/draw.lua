-- draw.lua: a panel under the input showing the current todo state
-- and the active subagents

local ui = blitz.ui
local todos = require("blitz-core.todo")

local ICON_CIRCLE = "\u{f111}"
local ICON_CIRCLE_OPEN = "\u{f10c}"
local ICON_BLANK = " "
local AGENT_COLOR = "#ff00ff"

local REFRESH_TICKS = 6
local BLINK_TICKS = 20

local STATE_DONE = "done"
local STATE_PROGRESS = "in_progress"
local STATE_PENDING = "pending"

local GROUPS = {
	{ state = STATE_DONE, color = "ok" },
	{ state = STATE_PROGRESS, color = "warn" },
	{ state = STATE_PENDING, color = "muted" },
}

local MAX_DONE = 3

local INACTIVE_STATES = {
	idle = true,
	complete = true,
	canceled = true,
	failed = true,
}

local function active_agents()
	local active = {}
	for _, a in ipairs(blitz.list_agents()) do
		if not INACTIVE_STATES[a.state] then
			active[#active + 1] = a
		end
	end
	return active
end

local function main_todos()
	local agent = blitz.get_main_agent()
	if not agent then
		return {}
	end
	return blitz.state.get("todo_" .. agent) or {}
end

local function group_color(state)
	for _, g in ipairs(GROUPS) do
		if g.state == state then
			return g.color
		end
	end
	return "muted"
end

local function shown_todos()
	local grouped = {}
	for _, t in ipairs(main_todos()) do
		grouped[t.state] = grouped[t.state] or {}
		local list = grouped[t.state]
		list[#list + 1] = t
	end
	local rows = {}
	for _, g in ipairs(GROUPS) do
		local list = grouped[g.state] or {}
		local first = 1
		if g.state == STATE_DONE then
			first = math.max(1, #list - MAX_DONE + 1)
		end
		for i = first, #list do
			rows[#rows + 1] = list[i]
		end
	end
	return rows
end

local function todo_rows()
	local rows = {}
	for _, t in ipairs(shown_todos()) do
		rows[#rows + 1] = {
			{ todos.marks[t.state], fg = group_color(t.state) },
			" #" .. t.id .. " " .. t.text,
		}
	end
	return rows
end

local function agent_rows(agents, blink_on)
	if #agents == 0 then
		return { { { ICON_CIRCLE_OPEN, fg = "muted" }, " no active agents" } }
	end
	local icon = blink_on and ICON_CIRCLE or ICON_BLANK
	local rows = {}
	for _, a in ipairs(agents) do
		local status = a.state .. " " .. math.floor(a.ctx or 0) .. "%"
		if a.tps and a.tps > 0 then
			status = status .. string.format(" %.1f tps", a.tps)
		end
		rows[#rows + 1] = {
			{ icon, fg = AGENT_COLOR },
			" " .. a.name .. " " .. status .. " ",
			{ a.task or "", fg = "muted" },
		}
	end
	return rows
end

local function signature(title, rows)
	local parts = { title }
	for _, spans in ipairs(rows) do
		for _, span in ipairs(spans) do
			parts[#parts + 1] = type(span) == "table" and span[1] or span
		end
		parts[#parts + 1] = "\n"
	end
	return table.concat(parts, "\0")
end

local function section(title)
	return {
		box = ui.box({ title = title, border = "muted", grow = 1, padding = { x = 1 } }),
		shown = nil,
	}
end

local function update(part, title, rows)
	local wanted = signature(title, rows)
	if wanted == part.shown then
		return
	end
	part.shown = wanted
	part.box:set({ title = title })
	part.box:clear()
	for _, spans in ipairs(rows) do
		part.box:add(ui.text(spans))
	end
end

local todo_section = section("Todos")
local agent_section = section("Active agents")

ui.mount(
	"below",
	ui.box({
		dir = "row",
		bg = "bg",
		min_height = 3,
		todo_section.box,
		agent_section.box,
	})
)

-- ui.root(ui.box({
--     ui.composer(),                               -- input on top
--     ui.slot({ name = "below" }),
--     ui.box({ dir = "row", grow = 1,
--         ui.timeline({ grow = 1 }),
--         ui.slot({ name = "right", dir = "row" }),
--     }),
-- }))

local ticks = 0

local function refresh()
	local agents = active_agents()
	local inactive = #blitz.list_agents() - #agents
	local blink_on = math.floor(ticks / BLINK_TICKS) % 2 == 0
	update(todo_section, "Todos", todo_rows())
	update(agent_section, "Active agents - inactive: " .. inactive, agent_rows(agents, blink_on))
end

blitz.hooks.tick(function()
	ticks = ticks + 1
	if ticks % REFRESH_TICKS == 0 then
		refresh()
	end
end)

refresh()
