local ok, godot = pcall(require, "godot")
if not ok then
	return
end

godot.setup()

local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end

map("n", "<leader>dr", godot.debugger.debug)
map("n", "<leader>dd", godot.debugger.debug_at_cursor)
map("n", "<leader>dc", godot.debugger.continue)
map("n", "<leader>ds", godot.debugger.step)
map("n", "<leader>dq", godot.debugger.quit)
