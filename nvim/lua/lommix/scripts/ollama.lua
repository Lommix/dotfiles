local plenary = require("plenary.window.float")
local Job = require("plenary.job")
local M = {}

M.opts = {
	prompt_args = { "--silent", "--no-buffer", "-X", "POST", "http://127.0.0.1:11434/api/generate", "-d" },
	chat_args = { "--silent", "--no-buffer", "-X", "POST", "http://127.0.0.1:11434/api/chat", "-d" },
}

local win_options = {
	winblend = 10,
	border = "rounded",
	out_bufnr = vim.api.nvim_create_buf(false, true),
	in_bufnr = vim.api.nvim_create_buf(false, true),
}

--- Add a message to the current chat.
--- @param chat_table table
--- @param buf_nr number
--- @param win_nr number
--- @param max_width number
--- @param callback function
--- @return number
M.chat = function(chat_table, buf_nr, win_nr, max_width, callback)
	local line = vim.api.nvim_buf_line_count(buf_nr)
	local line_char_count = 0
	local words = {}

	local success, json = pcall(function()
		return vim.fn.json_encode(chat_table)
	end)

	if not success then
		print("Error: " .. json)
		return -1
	end

	local args = vim.deepcopy(M.opts.chat_args)
	table.insert(args, json)

	local response = {
		role = "assistant",
		content = "",
	}

	chat_table.messages[#chat_table.messages + 1] = response

	local job = Job:new({
		command = "curl",
		args = args,
		on_stdout = function(_, data)
			vim.schedule(function()
				local success, result = pcall(function()
					return vim.fn.json_decode(data)
				end)

				if not success then
					print("Error: " .. result)
					return
				end

				if not result.done then
					local token = result.message.content

					if (string.match(token, "^%s") and line_char_count > max_width) or string.match(token, "\n") then -- if returned data array has more than one element, a line break occured.
						line = line + 1
						words = {}
						line_char_count = 0
					end

					line_char_count = line_char_count + #token

					-- remove newlines
					local t = token:gsub("\n", " ")
					table.insert(words, t)
					vim.api.nvim_buf_set_lines(buf_nr, line, line + 1, false, { table.concat(words, "") })

					-- scroll to bottom
					vim.api.nvim_win_set_cursor(win_nr, { line + 1, 0 })

					-- save response
					response.content = response.content .. result.message.content
				else
					callback()
				end
			end)
		end,
		on_stderr = function(_, data)
			print("Error: " .. data)
		end,
	})

	job:start()
	return job.pid
end

--- Prompt a single request against a model.
--- @param request table @fields: model, prompt.
--- @param buf_nr number
--- @param max_width number
--- @return number
M.prompt = function(request, buf_nr, max_width)
	local line = 0
	local line_char_count = 0
	local words = {}

	local success, json = pcall(function()
		return vim.fn.json_encode(request)
	end)

	if not success then
		print("Error: " .. json)
		return -1
	end

	local args = vim.deepcopy(M.opts.prompt_args)
	table.insert(args, json)

	local job = Job:new({
		command = "curl",
		args = args,
		on_stdout = function(_, data)
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(buf_nr) then
					job:stop()
				end

				local success, result = pcall(function()
					return vim.fn.json_decode(data)
				end)

				if not success then
					print("Error: " .. result)
					return
				end

				local token = result.response

				if (string.match(token, "^%s") and line_char_count > max_width) or string.match(token, "\n") then -- if returned data array has more than one element, a line break occured.
					line = line + 1
					words = {}
					line_char_count = 0
				end

				line_char_count = line_char_count + #token
				-- remove newlines
				local t = token:gsub("\n", " ")
				table.insert(words, t)
				vim.api.nvim_buf_set_lines(buf_nr, line, line + 1, false, { table.concat(words, "") })
			end)
		end,
	})

	job:start()
	return job.pid
end

--- Get the visual lines from the current buffer.
--- @return string
M.get_visual_lines = function(bufnr)
	local ESC_FEEDKEY = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

	vim.api.nvim_feedkeys(ESC_FEEDKEY, "n", true)
	vim.api.nvim_feedkeys("gv", "x", false)
	vim.api.nvim_feedkeys(ESC_FEEDKEY, "n", true)

	local start_row, start_col = unpack(vim.api.nvim_buf_get_mark(bufnr, "<"))
	local end_row, end_col = unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_row - 1, end_row, false)

	if start_row == 0 then
		lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		start_row = 1
		start_col = 0
		end_row = #lines
		end_col = #lines[#lines]
	end

	start_col = start_col + 1
	end_col = math.min(end_col, #lines[#lines] - 1) + 1

	lines[#lines] = lines[#lines]:sub(1, end_col)
	lines[1] = lines[1]:sub(start_col)

	return table.concat(lines, "\n")
end

return M
