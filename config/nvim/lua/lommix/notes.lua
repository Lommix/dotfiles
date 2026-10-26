local M = {}

local defaults = {
	path = "~/.quicky",
	popup_config = {
		size = {
			width = "90%",
			height = "90%",
		},
		position = "50%",
		enter = true,
		focusable = true,
		relative = "editor",
		border = {
			style = "rounded",
			text = {
				top = "Project Notes",
				top_align = "center",
			},
		},
		buf_options = {
			modifiable = true,
			readonly = false,
			swapfile = false,
			filetype = "markdown",
		},
		win_options = {
			winblend = 10,
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	},
}

local function notes_dir()
	local dir = vim.fs.normalize(defaults.path, { expand_env = false })
	vim.fn.mkdir(dir, "p")
	return dir
end

local function note_file(name)
	return vim.fs.joinpath(notes_dir(), name .. ".md")
end

local function git(dir, args)
	local cmd = { "git", "-C", dir }
	vim.list_extend(cmd, args)
	local ok, result = pcall(function()
		return vim.system(cmd, { text = true }):wait(10000)
	end)
	if not ok then
		return nil, tostring(result)
	end
	return result.code, result.stderr
end

local function ensure_repo(dir)
	if vim.fn.isdirectory(vim.fs.joinpath(dir, ".git")) == 1 then
		return true
	end
	local code, err = git(dir, { "init", "--quiet" })
	if code ~= 0 then
		return false, err
	end
	local ignore = vim.fs.joinpath(dir, ".gitignore")
	if vim.fn.filereadable(ignore) == 0 then
		pcall(vim.fn.writefile, { "*.tmp" }, ignore)
	end
	return true
end

local function commit(dir, path)
	local relative = vim.fs.relpath(dir, path)
	if not relative then
		return false, ("%s is outside %s"):format(path, dir)
	end
	local code, err = git(dir, { "add", "--", relative })
	if code ~= 0 then
		return false, err
	end
	code, err = git(dir, { "diff", "--cached", "--quiet", "--", relative })
	if code == 0 then
		return true
	end
	if code ~= 1 then
		return false, err
	end
	code, err = git(dir, { "commit", "--quiet", "--message", "wip: " .. vim.fs.basename(relative), "--", relative })
	if code ~= 0 then
		return false, err
	end
	return true
end

local function load(path)
	if vim.fn.filereadable(path) == 0 then
		return nil
	end
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok or type(lines) ~= "table" then
		return nil
	end
	return lines
end

local function size(path)
	local stat = vim.uv.fs_stat(path)
	return stat and stat.size or 0
end

local function persist(path, lines)
	local target = vim.uv.fs_realpath(path) or path
	local tmp = target .. ".tmp"
	local ok, ret = pcall(vim.fn.writefile, lines, tmp)
	if not ok or ret ~= 0 then
		pcall(vim.uv.fs_unlink, tmp)
		return false
	end
	local renamed, err = vim.uv.fs_rename(tmp, target)
	if not renamed then
		pcall(vim.uv.fs_unlink, tmp)
		return false, err
	end
	return true
end

local function close(popup, path, loaded, baseline)
	local lines = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
	local saved = path

	if not vim.deep_equal(lines, baseline) then
		if loaded == nil and size(path) > 0 then
			local rescue = ("%s.recovered-%s"):format(path, os.date("%Y%m%d-%H%M%S"))
			if not persist(rescue, lines) then
				vim.notify(("notes: cannot save %s, popup stays open"):format(rescue), vim.log.levels.ERROR)
				return
			end
			saved = rescue
			vim.notify(
				("notes: %s was unreadable, left it untouched and saved your text to %s"):format(path, rescue),
				vim.log.levels.ERROR
			)
		elseif not persist(path, lines) then
			vim.notify(("notes: cannot save %s, popup stays open"):format(path), vim.log.levels.ERROR)
			return
		end

		local dir = notes_dir()
		local repo_ready, repo_err = ensure_repo(dir)
		if not repo_ready then
			vim.notify(("notes: saved %s but git init failed: %s"):format(saved, repo_err), vim.log.levels.ERROR)
		else
			local committed, commit_err = commit(dir, saved)
			if not committed then
				vim.notify(("notes: saved %s but git commit failed: %s"):format(saved, commit_err), vim.log.levels.ERROR)
			end
		end
	end

	popup:hide()
	popup:unmount()
end

local function open(title, path)
	local ok, Popup = pcall(require, "nui.popup")
	if not ok then
		vim.notify("notes: nui.popup is not available", vim.log.levels.ERROR)
		return
	end

	local popup = Popup(vim.tbl_deep_extend("force", defaults.popup_config, {
		border = { text = { top = title } },
	}))
	popup:show()

	local loaded = load(path)
	local baseline = { "" }
	if loaded and #loaded > 0 then
		baseline = loaded
	end
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, baseline)
	vim.wo[popup.winid].number = true

	popup:map("n", "q", function()
		close(popup, path, loaded, baseline)
	end)
end

M.open_notes = function()
	open("Project Notes", note_file(string.gsub(vim.fn.getcwd(), "/", "")))
end

M.open_global_notes = function()
	open("Global Notes", note_file("global_note"))
end

vim.keymap.set("n", "<leader>j", M.open_global_notes, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>n", M.open_notes, { noremap = true, silent = true })
return M
