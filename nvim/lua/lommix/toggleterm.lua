local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

toggleterm.setup({
	size = 20,
	open_mapping = [[<C-T>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})

function _G.set_terminal_keymaps()
	local opts = { noremap = true }
	vim.api.nvim_buf_set_keymap(0, "t", "<A-h>", [[<C-\><C-n><C-W>h]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<A-j>", [[<C-\><C-n><C-W>j]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<A-k>", [[<C-\><C-n><C-W>k]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<A-l>", [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
	cmd = "lazygit",
	hidden = true,
	direction = "float",
	float_opts = {
		border = "none",
		width = 100000,
		height = 100000,
	},
	on_open = function(_)
		vim.cmd("startinsert!")
		-- vim.cmd "set laststatus=0"
	end,
	on_close = function(_)
		-- vim.cmd "set laststatus=3"
	end,
	count = 99,
})

local lazydocker = Terminal:new({
	cmd = "lazydocker",
	hidden = true,
	direction = "float",
	float_opts = {
		border = "none",
		width = 100000,
		height = 100000,
	},
	on_open = function(_)
		vim.cmd("startinsert!")
		-- vim.cmd "set laststatus=0"
	end,
	on_close = function(_)
		-- vim.cmd "set laststatus=3"
	end,
	count = 99,
})

local goquickrun = Terminal:new({
	cmd = "go run main.go",
	on_open = function(term)
		vim.api.nvim_buf_set_keymap(vim.api.nvim_get_current_buf(), "n", "q",":lua _GOQUICKRUN_KILL()<CR>", { silent = true })
	end,
})

-- dirty but worth it
function _GOQUICKRUN_KILL()
    goquickrun:shutdown()
end

function _GOQUICKRUN_TOGGLE()
    goquickrun:toggle()
end

function _LAZYDOCKER_TOGGLE()
	lazydocker:toggle()
end

function _LAZYGIT_TOGGLE()
	lazygit:toggle()
end
