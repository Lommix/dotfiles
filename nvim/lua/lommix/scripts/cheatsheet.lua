local M = {}

local a = vim.api
local response_buffer = a.nvim_create_buf(false, true)

local Job = require("plenary.job")
local url = "https://cht.sh"

local last_querytype = nil

---------------------------------------------------------------------------------
M.search = function()
	local question = vim.fn.input("Ask me anything: ")
	local firstWhiteSpace = string.find(question, "%s")
	local language, query, args

	if firstWhiteSpace ~= nil then
		language = string.sub(question, 1, firstWhiteSpace - 1)
		query = string.sub(question, firstWhiteSpace + 1)
		query = query:gsub("%s", "+")
		args = string.format("cht.sh/%s/%s?T", language, query)
	else
		language = line
		args = string.format("cht.sh/%s?T", language)
	end

	local editorWidth = a.nvim_get_option("columns")
	local editorHeight = a.nvim_get_option("lines")

	local response = {}
	local job = Job:new({
		command = "curl",
		args = { args },
		on_stdout = function(_, line)
			local s = line:gsub("\x1b%[%d+;%d+;%d+;%d+;%d+m", "")
				:gsub("\x1b%[%d+;%d+;%d+;%d+m", "")
				:gsub("\x1b%[%d+;%d+;%d+m", "")
				:gsub("\x1b%[%d+;%d+m", "")
				:gsub("\x1b%[%d+m", "")
			table.insert(response, s)
		end,
		on_exit = function()
			vim.schedule(function()
				response_window = a.nvim_open_win(response_buffer, true, {
					height = editorHeight - 20,
					width = editorWidth - 20,
					border = "double",
					relative = "editor",
					col = 10,
					row = 10,
				})
				a.nvim_buf_set_lines(response_buffer, 0, -1, true, response)
				a.nvim_buf_call(response_buffer, function()
					vim.cmd("setfiletype " .. language)
				end)
			end)
		end,
	}):start()
end

return M
