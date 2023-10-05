local M = {}

M.opts = {
	model = "mistral:instruct",
	cmd = "ollama run $model $prompt",
}

M.setup = function(opts)
	M.opts = vim.tbl_extend("force", M.opts, opts)
end

-- @param context string
-- @param prompt string
-- @param callback function
M.exec = function(context, prompt, callback)
	local args = vim.fn.shellescape(context .. "\n" .. prompt)
	local cmd = M.opts.cmd:gsub("$prompt", args)
	cmd = cmd:gsub("$model", M.opts.model, 1)

	local output = ""
	local job_id = vim.fn.jobstart(cmd, {
		on_stdout = function(_, data, _)
			output = output .. table.concat(data, "\n")
		end,
		on_exit = function(a, b)
			local lines = vim.split(output, "\n")
			callback(lines)
		end,
	})
end

M.run_in_term = function(prompt)
	local cmd = M.opts.cmd:gsub("$prompt", vim.fn.shellescape(prompt))
	cmd = cmd:gsub("$model", M.opts.model, 1)
	vim.cmd(":term " .. cmd)
end

M.run_visual_as_prompt = function()
	local prompt = vim.fn.shellescape(M.get_visual_selection())
	local cmd = M.opts.cmd:gsub("$prompt", "rewrite the following text for a tech blog in proper english: " .. prompt)
	cmd = cmd:gsub("$model", M.opts.model, 1)
	vim.cmd(":term " .. cmd)
end

M.get_visual_selection = function()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.api.nvim_buf_get_text(
		vim.api.nvim_get_current_buf(),
		start_pos[2] - 1,
		start_pos[3] - 1,
		end_pos[2] - 1,
		end_pos[3] - 1,
		{}
	)
	return table.concat(lines, "\n")
end

return M
