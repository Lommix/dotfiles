local todos = require("todo")

local ICON_CIRCLE = "\u{f111}"
local ICON_CIRCLE_OPEN = "\u{f10c}"

local MARK_X = 1
local MARK_WIDTH = 3
local TEXT_X = MARK_X + MARK_WIDTH + 1

local STATE_DONE = "done"
local STATE_PROGRESS = "in_progress"
local STATE_PENDING = "pending"

local GROUPS = {
	{ state = STATE_DONE, key = "ok" },
	{ state = STATE_PROGRESS, key = "warn" },
	{ state = STATE_PENDING, key = "muted" },
}

local function main_todos()
	local agent = blitz.get_main_agent()
	if not agent then
		return {}
	end
	return blitz.state.get("todo_" .. agent) or {}
end

local function cut(s, n)
	if #s <= n then
		return s
	end
	s = s:sub(1, math.max(0, n - 1))
	while #s > 0 and utf8.len(s) == nil do
		s = s:sub(1, #s - 1)
	end
	return s .. "…"
end

local panel
local panel_visible

local function wanted_height()
	return math.max(3, #main_todos() + 2, #blitz.list_agents() * 2 + 2)
end

local function needs_panel()
	return #main_todos() > 0 or #blitz.list_agents() >= 2
end

local function refresh_panel()
	local needed = needs_panel()
	if needed == panel_visible then
		return
	end
	panel_visible = needed
	if needed then
		panel.show()
	else
		panel.hide()
	end
end

panel = blitz.draw.panel({
	height = 3,
	place = "below",
	render = function(w, h, buf)
		refresh_panel()
		local agents = blitz.list_agents()
		local wanted = wanted_height()
		if wanted ~= h then
			panel.set_size(wanted)
		end
		buf.fill(0, 0, w, h, "bg")
		buf.box(0, 0, w, h, "muted")
		local theme = blitz.get_theme()

		local mid = math.floor(w / 2)
		buf.box(0, 0, mid, h, "muted")
		buf.box(mid, 0, w - mid, h, "muted")
		buf.set_color(1, 0, " Todos ", "info")
		buf.set_color(mid + 1, 0, " Agents ", "info")

		local todo_rows = {}
		for _, g in ipairs(GROUPS) do
			for _, t in ipairs(main_todos()) do
				if t.state == g.state then
					todo_rows[#todo_rows + 1] = {
						mark = todos.marks[t.state],
						color = theme[g.key] or "#8a8a8a",
						text = cut("#" .. t.id .. " " .. t.text, mid - TEXT_X - 1),
					}
				end
			end
		end

		local bottom = h - 2
		local y = 1
		for _, r in ipairs(todo_rows) do
			if y > bottom then
				break
			end
			buf.set_color(MARK_X, y, r.mark, r.color)
			buf.set(TEXT_X, y, r.text)
			y = y + 1
		end

		local ax = mid + 1
		if #agents == 0 then
			buf.set_color(ax, 1, ICON_CIRCLE_OPEN, "muted")
			buf.set(ax + 2, 1, cut("no agents yet", w - mid - 4))
			return
		end
		y = 1
		local budget = w - mid - 4
		for _, a in ipairs(agents) do
			if y + 1 > bottom then
				break
			end
			local busy = a.state ~= "idle" and a.state ~= "complete" and a.state ~= "canceled" and a.state ~= "failed"
			local color = not busy and "muted" or (a.state == "failed" and theme.err or "#ff00ff")
			buf.set_color(ax, y, busy and ICON_CIRCLE or ICON_CIRCLE_OPEN, color)
			buf.set(ax + 2, y, cut(a.name, budget - 16))
			buf.set(ax + 2 + #a.name + 1, y, a.state .. " " .. math.floor(a.ctx or 0) .. "%")
			buf.set_color(ax + 2, y + 1, cut(a.task or "", budget), "muted")
			y = y + 2
		end
	end,
})

blitz.hooks.inject(function(agent_id)
	refresh_panel()
	if todos.inject then
		return todos.inject(agent_id)
	end
end)
