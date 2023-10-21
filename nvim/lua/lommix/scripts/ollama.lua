local M = {}

local ESC_FEEDKEY = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

--- @param model string
--- @param context string
--- @param prompt string
--- @param buf_nr number
--- @param max_width number
--- @return number
M.run = function(model, context, prompt, buf_nr, max_width)
	local cmd = ("ollama run $model $prompt")
		:gsub("$model", model)
		:gsub("$prompt", vim.fn.shellescape(context .. "\n" .. prompt))
	local header = vim.split(prompt, "\n")
	table.insert(header, "----------------------------------------")
	vim.api.nvim_buf_set_lines(buf_nr, 0, -1, false, header)
	local line = vim.tbl_count(header)
	local line_char_count = 0
	local words = {}
	return vim.fn.jobstart(cmd, {
		on_stdout = function(_, data, _)
			for i, token in ipairs(data) do
				if i > 1 or (string.match(token, "^%s") and line_char_count > max_width) then -- if returned data array has more than one element, a line break occured.
					line = line + 1
					words = {}
					line_char_count = 0
				end
				line_char_count = line_char_count + #token
				table.insert(words, token)
				vim.api.nvim_buf_set_lines(buf_nr, line, line + 1, false, { table.concat(words, "") })
			end
		end,
	})
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
