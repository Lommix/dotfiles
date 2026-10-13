local SOURCE = "blitzdenk"

local function pane()
	if os.getenv("HERDR_ENV") ~= "1" then
		return ""
	end
	return os.getenv("HERDR_PANE_ID") or ""
end

local function next_seq()
	local last = tonumber(blitz.state.get("herdr_seq")) or 0
	local now = os.time()
	if now <= last then
		now = last + 1
	end
	blitz.state.set("herdr_seq", now)
	return now
end

local function report_cmd(state, seq)
	return "\"$HERDR_BIN_PATH\" pane report-agent \"$HERDR_PANE_ID\" --source " .. SOURCE
		.. " --agent " .. SOURCE
		.. " --state " .. state
		.. " --seq " .. seq
end

local function release_cmd(seq)
	return "\"$HERDR_BIN_PATH\" pane release-agent \"$HERDR_PANE_ID\" --source " .. SOURCE
		.. " --agent " .. SOURCE
		.. " --seq " .. seq
end

local function publish(state)
	local p = pane()
	if p == "" then
		return
	end
	local key = "herdr_blitz_" .. p
	if blitz.state.get(key) == state then
		return
	end
	local _, ok = blitz.shell({ cmd = report_cmd(state, next_seq()), force_local = true, timeout = 5 })
	if ok then
		blitz.state.set(key, state)
	end
end

local function reset()
	local p = pane()
	if p == "" then
		return
	end
	local _, ok = blitz.shell({ cmd = release_cmd(next_seq()), force_local = true, timeout = 5 })
	if ok then
		blitz.state.set("herdr_blitz_" .. p, nil)
	end
end

local function mine(ev)
	return ev.id == blitz.get_main_agent()
end

blitz.hooks.agent_started(function(ev) if mine(ev) then publish("working") end end)
blitz.hooks.user_message_sent(function() publish("working") end)
blitz.hooks.agent_complete(function(ev) if mine(ev) then publish("idle") end end)
blitz.hooks.agent_failed(function(ev) if mine(ev) then publish("idle") end end)
blitz.hooks.agent_cancelled(function(ev) if mine(ev) then publish("idle") end end)
blitz.hooks.session_reset(reset)
