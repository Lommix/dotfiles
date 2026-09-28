--- ! Memory tool, runs after each agent turn, compacts new facts into a MEMORY.md file. Experimental

local M = {}

-- M.compressor_id = blitz.add_agent({
-- 	name = "compressor",
-- 	description = "extract durable facts for long term memory",
-- 	prompt = require("prompts").memory_compressor,
-- 	model = require("provider").ds_flash,
-- 	tools = { blitz.tools.EDIT, blitz.tools.WRITE, blitz.tools.GLOB, blitz.tools.GREP, blitz.tools.READ },
-- 	in_agent_tool = false,
-- })

-- blitz.hooks.inject({
-- 	main_only = true,
-- 	digest = true,
-- 	func = function()
-- 		local f = io.open("MEMORY.md", "r")
-- 		if not f then
-- 			return nil
-- 		end
-- 		f:close()
-- 		return "The project has an agent MEMORY.md file, read it"
-- 	end,
-- })

-- blitz.hooks.agent_complete(function(ev)
-- 	if ev.id ~= blitz.get_main_agent() then
-- 		return
-- 	end
-- 	local rows = blitz.agent.history_since_checkpoint(ev.id)
-- 	local chunk = {}
--
-- 	-- skip small context
-- 	if #rows < 8 then
-- 		return
-- 	end
--
-- 	for i, row in ipairs(rows) do
-- 		chunk[i] = row.role .. ": " .. row.text
-- 	end
--
-- 	blitz.push_notification("starting mem compression")
--
-- 	local id = blitz.agent.spawn({
-- 		agent_type = M.compressor_id,
-- 		prompt = table.concat(chunk, "\n"),
-- 		background = true,
-- 		clean = true,
-- 	})
--
-- 	if id == nil then
-- 		blitz.push_notification("failed to start memory agent")
-- 		return
-- 	end
--
-- 	if blitz.agent.await(id) == blitz.AWAIT_COMPLETE then
-- 		blitz.push_notification("memory extracted")
-- 	else
-- 		blitz.push_notification("memory extraction failed")
-- 	end
-- 	blitz.agent.close(id)
-- end)

return M
