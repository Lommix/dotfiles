-- draw.lua: a simple panel showing the current todo state
-- and all subagents

local todos = require("todo")

local ICON_CIRCLE = "\u{f111}"
local ICON_CIRCLE_OPEN = "\u{f10c}"
local ICON_BLANK = " "

local BLINK_FRAMES = 20

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

local function wanted_height()
	return math.max(3, #main_todos() + 2, #blitz.list_agents() + 2)
end

panel = blitz.draw.panel({
	height = 3,
	place = "below",
	render = function(w, h, buf, frame)
		local agents = blitz.list_agents()
		local wanted = wanted_height()
		if wanted ~= h then
			panel.set_size(wanted)
		end
		local blink_on = math.floor(frame / BLINK_FRAMES) % 2 == 0
		local blinking = false
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
			if y > bottom then
				break
			end
			local busy = a.state ~= "idle" and a.state ~= "complete" and a.state ~= "canceled" and a.state ~= "failed"
			local color = not busy and "muted" or (a.state == "failed" and theme.err or "#ff00ff")
			local icon = busy and ICON_CIRCLE or ICON_CIRCLE_OPEN
			if busy then
				blinking = true
				if not blink_on then
					icon = ICON_BLANK
				end
			end
			local status = a.state .. " " .. math.floor(a.ctx or 0) .. "%"
			if a.tps and a.tps > 0 then
				status = status .. string.format(" %.1f tps", a.tps)
			end
			local name = cut(a.name, budget - #status - 4)
			buf.set_color(ax, y, icon, color)
			local nx = ax + 2
			buf.set(nx, y, name .. " ")
			nx = nx + #name + 1
			buf.set(nx, y, status .. " ")
			nx = nx + #status + 1
			buf.set_color(nx, y, cut(a.task or "", w - nx - 1), "muted")
			y = y + 1
		end
		if blinking then
			blitz.draw.redraw()
		end
	end,
})
