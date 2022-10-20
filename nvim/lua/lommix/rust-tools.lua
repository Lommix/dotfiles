local ok, rt = pcall(require, "rust-tools")
if not ok then
	return
end

local opts = {
	server = {
		on_attach = function(_, bufnr)
			-- Hover actions
			vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
			-- Code action groups
			vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
		end,
	},
	-- fix this shit
	dap = {
		adapter = {
			type = "executable",
			command = "lldb-vscode-14",
			name = "lldb-vscode-14",
		},
	},
}

rt.setup(opts)
