local M = {}

local SOURCE = "blitzdenk"
local META_SOURCE = "blitzdenk:meta"

local TICK_SECONDS = 1
local FULL_SYNC_SECONDS = 300
local BLOCK_GRACE_SECONDS = 1
local TOKEN_MAX = 70
local SHELL_TIMEOUT = 2

local WORK = {
	thinking = "thinking",
	writing = "writing",
	calling = "calling tools",
	processing = "processing",
	retrying = "retrying",
	compacting = "compacting",
	running = "running",
	waiting = "waiting",
}

local WORKING = {}
for state in pairs(WORK) do
	WORKING[state] = true
end

local STATUSES = { "working", "blocked", "idle" }
local TOKENS = { "model", "effort", "ctx", "tps", "queued", "todo", "cost" }

local function pane()
	if os.getenv("HERDR_ENV") ~= "1" then
		return nil
	end
	local id = os.getenv("HERDR_PANE_ID")
	if id == nil or id == "" then
		return nil
	end
	return id
end

local function next_seq(key)
	local last = tonumber(blitz.state.get(key)) or 0
	local now = os.time()
	if now <= last then
		now = last + 1
	end
	blitz.state.set(key, now)
	return now
end

local function shq(text)
	return "'" .. tostring(text):gsub("'", "'\\''") .. "'"
end

local function cut(text, max)
	if #text <= max then
		return text
	end
	text = text:sub(1, max)
	while #text > 0 and utf8.len(text) == nil do
		text = text:sub(1, #text - 1)
	end
	return text .. "…"
end

local function clean(text)
	text = tostring(text or "")
	text = text:gsub("%c+", " ")
	text = text:gsub("%s+", " ")
	text = text:gsub("^%s*(.-)%s*$", "%1")
	return cut(text, TOKEN_MAX)
end

local function run(cmd)
	local _, ok = blitz.shell({ cmd = cmd, force_local = true, timeout = SHELL_TIMEOUT })
	return ok
end

local function main_row()
	local id = blitz.get_main_agent()
	if not id then
		return nil
	end
	for _, row in ipairs(blitz.list_agents()) do
		if row.agent_id == id then
			return row
		end
	end
	return nil
end

local function main_blocker()
	local id = blitz.get_main_agent()
	if not id then
		return nil
	end
	for _, pending in ipairs(blitz.permissions.list_pending()) do
		if pending.agent_id == id then
			return pending
		end
	end
	return nil
end

local function blocker_label(blocker)
	if blocker.kind == "ask" then
		return "question"
	end
	if blocker.kind == "plan" then
		return "review plan"
	end
	if blocker.kind == "diff" then
		return "review patch"
	end
	return "approve " .. (blocker.tool or "tool")
end

local function blocker_message(blocker)
	if blocker.kind == "ask" then
		return clean(blocker.question or blocker.header or "waiting for an answer")
	end
	if blocker.kind == "diff" or blocker.kind == "plan" then
		return clean(blocker.path or "waiting for a review")
	end
	return clean(blocker.description or blocker.tool or "waiting for approval")
end

local function current_todo(agent_id)
	local pending
	for _, item in ipairs(blitz.state.get("todo_" .. agent_id) or {}) do
		if item.state == "in_progress" then
			return clean(item.text)
		end
		if item.state == "pending" and not pending then
			pending = item
		end
	end
	if pending then
		return clean(pending.text)
	end
	return nil
end

local function tokens_for(row)
	local tokens = {
		ctx = tostring(math.floor(row.ctx or 0)),
		model = clean(row.model),
		effort = clean(blitz.agent.get_effort(row.agent_id)),
		todo = current_todo(row.agent_id),
	}
	if row.tps and row.tps >= 1 then
		tokens.tps = string.format("%.1f", row.tps)
	end
	if row.queued and row.queued > 0 then
		tokens.queued = tostring(row.queued)
	end
	local use = blitz.token_usage()
	if use and (use.cost or 0) >= 0.01 then
		tokens.cost = string.format("$%.2f", use.cost)
	end
	return tokens
end

local function derive(pane_id, row)
	local ok, tokens = pcall(tokens_for, row)
	if not ok then
		tokens = { ctx = tostring(math.floor(row.ctx or 0)) }
	end
	local blocker = main_blocker()
	local since_key = "herdr_block_since_" .. pane_id
	if blocker then
		local since = blitz.state.get(since_key)
		if since == nil then
			blitz.state.set(since_key, os.time())
		elseif os.time() - since >= BLOCK_GRACE_SECONDS then
			return "blocked", blocker_label(blocker), blocker_message(blocker), tokens
		end
	elseif blitz.state.get(since_key) ~= nil then
		blitz.state.set(since_key, nil)
	end
	if WORKING[row.state] then
		return "working", WORK[row.state], "", tokens
	end
	return "idle", "", "", tokens
end

local function state_report(pane_id, state, message)
	local state_key = "herdr_state_" .. pane_id
	local msg_key = "herdr_msg_" .. pane_id
	if blitz.state.get(state_key) == state and (blitz.state.get(msg_key) or "") == message then
		return
	end
	local cmd = "\"$HERDR_BIN_PATH\" pane report-agent \"$HERDR_PANE_ID\""
		.. " --source " .. SOURCE
		.. " --agent " .. SOURCE
		.. " --state " .. state
		.. " --message " .. shq(message)
		.. " --seq " .. next_seq("herdr_seq")
	if run(cmd) then
		blitz.state.set(state_key, state)
		blitz.state.set(msg_key, message)
	end
end

local function meta_report(pane_id, state, label, tokens)
	local args = {}
	local pending = {}
	for _, status in ipairs(STATUSES) do
		local key = "herdr_label_" .. pane_id .. "_" .. status
		local value = status == state and label or ""
		if value ~= (blitz.state.get(key) or "") then
			args[#args + 1] = "--state-label " .. status .. "=" .. shq(value)
			pending[#pending + 1] = { key = key, value = value }
		end
	end
	for _, name in ipairs(TOKENS) do
		local key = "herdr_tok_" .. pane_id .. "_" .. name
		local value = tokens[name] or ""
		if value ~= (blitz.state.get(key) or "") then
			if value == "" then
				args[#args + 1] = "--clear-token " .. name
			else
				args[#args + 1] = "--token " .. name .. "=" .. shq(value)
			end
			pending[#pending + 1] = { key = key, value = value }
		end
	end
	if #args == 0 then
		return
	end
	local cmd = "\"$HERDR_BIN_PATH\" pane report-metadata \"$HERDR_PANE_ID\""
		.. " --source " .. META_SOURCE
		.. " --agent " .. SOURCE
		.. " --applies-to-source " .. SOURCE
		.. " --seq " .. next_seq("herdr_meta_seq")
		.. " " .. table.concat(args, " ")
	if run(cmd) then
		for _, item in ipairs(pending) do
			blitz.state.set(item.key, item.value)
		end
	end
end

local function clear_cache(pane_id)
	for _, status in ipairs(STATUSES) do
		blitz.state.set("herdr_label_" .. pane_id .. "_" .. status, nil)
	end
	for _, name in ipairs(TOKENS) do
		blitz.state.set("herdr_tok_" .. pane_id .. "_" .. name, nil)
	end
	blitz.state.set("herdr_state_" .. pane_id, nil)
	blitz.state.set("herdr_msg_" .. pane_id, nil)
	blitz.state.set("herdr_block_since_" .. pane_id, nil)
end

local function push_now()
	local pane_id = pane()
	if not pane_id then
		return
	end
	local row = main_row()
	if not row then
		return
	end
	local state, label, message, tokens = derive(pane_id, row)
	state_report(pane_id, state, message)
	meta_report(pane_id, state, label, tokens)
end

function M.push()
	local ok, err = pcall(push_now)
	if not ok then
		blitz.log("herdr push failed: " .. tostring(err))
	end
end

local last_tick = 0
local last_sync = 0

local function tick_now()
	local now = os.time()
	if now - last_tick < TICK_SECONDS then
		return
	end
	last_tick = now
	if now - last_sync >= FULL_SYNC_SECONDS then
		last_sync = now
		local pane_id = pane()
		if pane_id then
			clear_cache(pane_id)
		end
	end
	push_now()
end

function M.tick()
	local ok, err = pcall(tick_now)
	if not ok then
		blitz.log("herdr tick failed: " .. tostring(err))
	end
end

local function release()
	local pane_id = pane()
	if not pane_id then
		return
	end
	local cmd = "\"$HERDR_BIN_PATH\" pane release-agent \"$HERDR_PANE_ID\""
		.. " --source " .. SOURCE
		.. " --agent " .. SOURCE
		.. " --seq " .. next_seq("herdr_seq")
	if run(cmd) then
		clear_cache(pane_id)
	end
end

local function mine(ev)
	return ev.id == blitz.get_main_agent()
end

blitz.hooks.agent_started(function(ev)
	if mine(ev) then
		M.push()
	end
end)

blitz.hooks.user_message_sent(function()
	M.push()
end)

blitz.hooks.agent_complete(function(ev)
	if mine(ev) then
		M.push()
	end
end)

blitz.hooks.agent_failed(function(ev)
	if mine(ev) then
		M.push()
	end
end)

blitz.hooks.agent_cancelled(function(ev)
	if mine(ev) then
		M.push()
	end
end)

blitz.hooks.permission_requested(function()
	M.push()
end)

blitz.hooks.session_reset(function()
	release()
end)

return M
