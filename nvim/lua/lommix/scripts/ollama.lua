local Job = require("plenary.job")
local M = {}

local PromptArgs = { "--silent", "--no-buffer", "-X", "POST", "http://127.0.0.1:11434/api/generate", "-d" }
local ChatArgs = { "--silent", "--no-buffer", "-X", "POST", "http://127.0.0.1:11434/api/chat", "-d" }

local ESC_FEEDKEY = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

--- @param request table
--- @param buf_nr number
--- @param max_width number
--- @return number
M.run = function(request, buf_nr, max_width)
	local header = {}
	local line = vim.tbl_count(header)
	local line_char_count = 0
	local words = {}

	local success, json = pcall(function()
		return vim.fn.json_encode(request)
	end)

	if not success then
		print("Error: " .. json)
		return -1
	end

	local args = vim.deepcopy(PromptArgs)
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

				if ( string.match(token, "^%s") and line_char_count > max_width ) or string.match(token, "\n") then -- if returned data array has more than one element, a line break occured.
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
		-- Callback when the job has some data on stderr
		on_stderr = function(_, data)
			print("stderr: " .. data)
		end,
		-- Callback when the job is done
		on_exit = function(j, return_val)
			print("Job finished with return value: " .. return_val)
		end,
	})
	job:start()
	return job.pid
end

--- @return string
M.get_visual_lines = function(bufnr)
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
