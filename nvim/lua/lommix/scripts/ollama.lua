local M = {}

M.opts = {
	model = "mistral:instruct",
	cmd = "ollama run $model $prompt",
}

M.setup = function(opts)
	M.opts = vim.tbl_extend("force", M.opts, opts)
end

M.run_in_term = function(prompt)
	local cmd = M.opts.cmd:gsub("$prompt", prompt)
	cmd = cmd:gsub("$model", M.opts.model, 1)
	vim.cmd(":term " .. cmd)
end

M.run_visual_as_prompt = function()
	local prompt = M.get_visual_selection()
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
