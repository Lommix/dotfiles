local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- split movement : linux
map("n", "<A-h>", "<C-w>h")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-l>", "<C-w>l")

-- split movement : mac
map("n", "ª", "<C-w>h")
map("n", "º", "<C-w>j")
map("n", "∆", "<C-w>k")
map("n", "@", "<C-w>l")

-- split
map("n", "<leader>V", "<CMD>split<CR>")
map("n", "<leader>v", "<CMD>vsplit<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>e", ":NvimTreeFindFileToggle<CR>:NvimTreeFocus<CR>")

map("n", "<leader>j", ":resize -2<CR>")
map("n", "<leader>k", ":resize +2<CR>")
map("n", "<leader>l", ":vertical resize -2<CR>")
map("n", "<leader>h", ":vertical resize +2<CR>")
-- git
map("n", "<leader>gg", ":lua _LAZYGIT_TOGGLE()<CR>")
-- telescope
map("n", "<leader>ff", ":lua require'telescope.builtin'.find_files{}<CR>")
map("n", "<leader>fr", ":lua require'telescope.builtin'.find_files{no_ignore = true}<CR>")
map("n", "<leader>fg", ":lua require'telescope.builtin'.live_grep{additionals_args={'--no-ignore'}}<CR>")
map("n", "<leader>fs", ":lua require'telescope.builtin'.grep_string()<CR>")
map("n", "<leader>fb", "<CMD>Telescope buffers<CR>")
map("n", "<leader>fh", "<CMD>Telescope help_tags<CR>")

-- lsp
map("n", "<A-f>", vim.lsp.buf.formatting_sync)
map("n", "ƒ", vim.lsp.buf.formatting_sync)
--map("n", "K", vim.lsp.buf.hover)
map("n", "K", "<Cmd>Lspsaga hover_doc<CR>")

map("n", "gd", "<cmd>Lspsaga peek_definition<CR>")
map("n", "gD", "<cmd>Lspsaga lsp_finder<CR>")
map("n", "gi", "<cmd>Telescope lsp_implementations<CR>")
--map("n", "gr", "<cmd>Telescope lsp_references<CR>")
map("n", "gp", "<Cmd>Lspsaga preview_definition<CR>")
map("n", "gr", "<Cmd>Lspsaga rename<CR>")
map("n", "gn", "<cmd>Telescope diagnostics<CR>")
map("n", "gt", ":lua vim.lsp.buf.code_action()<CR>")
-- clear highlight search
map("n", "<CR>", "<CR> :noh<CR><CR>")

map("n", "<leader>r", ":lua require('nvim-reload').Reload()<CR>:syntax on<CR>")
map("n", "<leader>i", ":LspInfo<CR>")

local shopware = require("plugins.shopware")
map("n", "<leader>sc", shopware.get_services)
map("n", "<leader>ss", ":lua require'plugins.shopware'.get_and_copy_services()<CR>")

-- godot
local godot = require("godot")
map("n", "<leader>b", function()
	package.loaded["godot"] = nil
	godot = require("godot")
	godot.debug_at_cursor()
end)
--map("n", "<leader>d", godot.debug_at_cursor)
