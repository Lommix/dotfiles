local M = {}

local state = {
	win = nil,
	buf = nil,
	path = nil,
	group = nil,
	debounce = nil,
}

local function image_at_cursor()
	local oil = require("oil")
	local entry = oil.get_cursor_entry()
	if not entry or entry.type ~= "file" then
		return nil
	end
	if not Snacks.image.supports_file(entry.name) then
		return nil
	end
	local dir = oil.get_current_dir()
	if not dir then
		return nil
	end
	return dir .. entry.name
end

local function set_title(name)
	vim.api.nvim_win_set_config(state.win, {
		title = " " .. name .. " ",
		title_pos = "center",
	})
end

local function stop_debounce()
	if state.debounce and not state.debounce:is_closing() then
		state.debounce:stop()
		state.debounce:close()
	end
	state.debounce = nil
end

local function follow()
	if not state.win or not vim.api.nvim_win_is_valid(state.win) then
		return
	end
	stop_debounce()
	state.debounce = vim.defer_fn(function()
		local path = image_at_cursor()
		if not path then
			M.close()
			return
		end
		if path == state.path then
			return
		end
		state.path = path
		Snacks.image.buf.attach(state.buf, { src = path })
		set_title(vim.fs.basename(path))
	end, 50)
end

function M.close()
	stop_debounce()
	if state.group then
		vim.api.nvim_del_augroup_by_id(state.group)
		state.group = nil
	end
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
	end
	state.win = nil
	state.buf = nil
	state.path = nil
end

function M.open()
	local path = image_at_cursor()
	if not path then
		return false
	end
	M.close()

	state.path = path
	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "wipe"
	vim.bo[state.buf].buftype = "nofile"

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	state.win = vim.api.nvim_open_win(state.buf, false, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		border = "rounded",
		title = " " .. vim.fs.basename(path) .. " ",
		title_pos = "center",
		style = "minimal",
		zindex = 50,
	})

	vim.keymap.set("n", "q", M.close, { buffer = state.buf, silent = true })
	vim.keymap.set("n", "<Esc>", M.close, { buffer = state.buf, silent = true })

	local oil_buf = vim.api.nvim_get_current_buf()
	state.group = vim.api.nvim_create_augroup("lommix_oil_image", { clear = true })
	vim.api.nvim_create_autocmd("CursorMoved", {
		group = state.group,
		buffer = oil_buf,
		callback = follow,
	})
	vim.api.nvim_create_autocmd("BufLeave", {
		group = state.group,
		buffer = oil_buf,
		callback = M.close,
	})
	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = state.group,
		buffer = oil_buf,
		callback = M.close,
	})

	Snacks.image.buf.attach(state.buf, { src = path })
	return true
end

function M.toggle()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		M.close()
	else
		M.open()
	end
end

return M
