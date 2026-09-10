-- voice.lua: C-r toggles voice recording. First press records the mic,
-- second press stops, transcribes and pastes the text into the input box.
-- Engine: nvidia/nemotron-3.5-asr-streaming-0.6b via transcribe.cpp (local, sync).

local CLI = "/home/lommix/Projects/vendor/transcribe.cpp/build/bin/transcribe-cli"
local MODEL = "/home/lommix/Projects/vendor/localai/models/nemotron-3.5-asr-streaming-0.6b-Q8_0.gguf"
local DIR = "/tmp/blitz-voice"
local RATE = 16000
local LANG = "en-US"

local recording = false

local function notify(msg)
	blitz.push_notification("voice: " .. msg)
end

local function start()
	blitz.shell({
		cmd = "pkill -INT -f '[f]fmpeg.*blitz-voice' 2>/dev/null; rm -rf " .. DIR .. "; mkdir -p " .. DIR,
	})
	blitz.shell({
		cmd = "nohup ffmpeg -nostats -loglevel error -f pulse -i default"
			.. string.format(" -ar %d -ac 1 -f s16le %s/live.pcm", RATE, DIR)
			.. " > /dev/null 2>&1 < /dev/null &",
	})
	recording = true
	notify("talk, C-r to stop")
end

local function stop()
	recording = false
	local lang = LANG ~= "auto" and (" --language " .. LANG) or ""
	local out, ok = blitz.shell({
		cmd = [[
pkill -INT -f '[f]fmpeg.*blitz-voice' 2>/dev/null
i=0
while pgrep -f '[f]fmpeg.*blitz-voice' >/dev/null 2>&1 && [ $i -lt 40 ]; do sleep 0.1; i=$((i+1)); done
python3 -c '
import struct
pcm = open("/tmp/blitz-voice/live.pcm", "rb").read()
w = b"RIFF" + struct.pack("<I", 36 + len(pcm)) + b"WAVEfmt "
w += struct.pack("<IHHIIHH", 16, 1, 1, 16000, 32000, 2, 16)
w += b"data" + struct.pack("<I", len(pcm)) + pcm
open("/tmp/blitz-voice/live.wav", "wb").write(w)'
]] .. CLI .. " -q -m " .. MODEL .. lang .. " " .. DIR .. "/live.wav",
		timeout = 300,
	})
	if not ok then
		notify("transcribe failed")
		return
	end
	local text = out:match("text: ([^\n]*)")
	if not text or text == "" then
		notify("nothing heard")
		return
	end
	blitz.input.append(text)
end

blitz.bind("<C-r>", function()
	if recording then
		stop()
	else
		start()
	end
end, "voice input")

---------------------------------------------------------------------------------------------------
--- C-f prompt refiner
---------------------------------------------------------------------------------------------------
local models = require("provider")

local refine_prompt =
	[[You rewrite drafts into prompts for a coding agent. That agent has shell, file, search, and subagent tools and works in a live project. You have no tools and answer in exactly one message.

The user message is the raw content of an input box. Your entire reply is the rewritten prompt, nothing else: no preamble, no explanation, no questions, no markdown fences.

Work through this silently, then write the rewrite:


Before writing any prompt, silently extract these 9 dimensions

| Dimension            | What to extract                                             | Critical?              |
| -------------------- | ----------------------------------------------------------- | ---------------------- |
| **Task**             | Specific action — convert vague verbs to precise operations | Always                 |
| **Output format**    | Shape, length, structure, filetype of the result            | Always                 |
| **Constraints**      | What MUST and MUST NOT happen, scope boundaries             | If complex             |
| **Input**            | What the user is providing alongside the prompt             | If applicable          |
| **Context**          | Domain, project state, prior decisions from this session    | If session has history |
| **Audience**         | Who reads the output, their technical level                 | If user-facing         |
| **Success criteria** | How to know the prompt worked — binary where possible       | If task is complex     |
| **Examples**         | Desired input/output pairs for pattern lock                 | If format-critical     |

1. Extract the intent: the task, the wanted result, the constraints, the given inputs, and how success is checked.
2. Turn vague verbs into precise operations. Name files, commands, and identifiers exactly as the draft names them.
3. Keep every concrete detail: paths, numbers, error text, code identifiers. Invent nothing: no new requirements, no guessed paths, no added scope.
4. Drop filler, hedging, and repetition. Compress until every sentence carries an instruction or a fact.
5. Structure only when it helps: short paragraphs, or a compact list for multi step work.
6. Write the rewrite in the language of the draft. Keep a leading slash command token unchanged.

A draft that is already tight stays almost as it is. Polish it, do not inflate it.

Writing rules for the rewrite:
- Plain words. Never use: additionally, crucial, delve, enhance, foster, garner, interplay, intricate, landscape, pivotal, showcase, tapestry, testament, underscore, vibrant, leverage, utilize.
- Active voice. Short sentences, one idea each.
- No em dashes. No "not just X, but Y". No forced groups of three. No synonym cycling.
- Say what to do, not how it feels. Name the mechanism, the file, the command.
- No chatbot phrases, no hedging, no generic closing line.]]

local prompter = blitz.add_agent({
	name = "prompter",
	description = "Internal. Rewrites the input box draft into a tight prompt. Has no tools.",
	prompt = refine_prompt,
	effort = "low",
	model = models.ds_flash,
	tools = {},
	in_agent_tool = false,
})
blitz.state.set("refine_type", prompter)

local refine_dead = { idle = true, complete = true, canceled = true, failed = true }

local function refine_busy(id)
	if id == nil then
		return false
	end
	for _, a in ipairs(blitz.list_agents()) do
		if a.agent_id == id then
			return not refine_dead[a.state]
		end
	end
	return false
end

local function refine_clear()
	blitz.state.set("refine_agent", nil)
	blitz.state.set("refine_root", nil)
end

blitz.hooks.agent_failed(function(ev)
	local id = blitz.state.get("refine_agent")
	if id ~= nil and ev.id == id then
		refine_clear()
		blitz.push_notification("prompter failed: " .. ev.err)
	end
end)

blitz.hooks.agent_cancelled(function(ev)
	local id = blitz.state.get("refine_agent")
	if id ~= nil and ev.id == id then
		refine_clear()
		blitz.push_notification("prompter canceled, input unchanged")
	end
end)

blitz.bind("<C-f>", function()
	local pending = blitz.state.get("refine_agent")
	if refine_busy(pending) then
		notify("still refining")
		return
	end
	local text = blitz.input.get()
	if text:match("^%s*$") then
		notify("input is empty")
		return
	end
	local parent = blitz.get_main_agent()
	local id = blitz.agent.spawn({
		agent_type = prompter,
		parent_id = parent,
		prompt = text,
		task = "refine input box",
		background = true,
		on_complete = function(agent_id, _)
			local result = blitz.agent.result(agent_id)
			if result then
				blitz.input.set(result)
			end

			blitz.agent.close(agent_id)
		end,
	})
	if id == nil then
		notify("no free agent slot")
		return
	end
	blitz.state.set("refine_agent", id)
	notify("refining")
end, "refine prompt")
