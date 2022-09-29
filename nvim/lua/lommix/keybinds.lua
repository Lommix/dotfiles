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



map("n", "<C-Right>", "<C-w><")
map("n", "<C-Left>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")

--map("n", "<leader>j", ":resize -2<CR>")
--map("n", "<leader>k", ":resize +2<CR>")
--map("n", "<leader>l", ":vertical resize -2<CR>")
--map("n", "<leader>h", ":vertical resize +2<CR>")
-- git
map("n", "<leader>lg", ":lua _LAZYGIT_TOGGLE()<CR>")
map("n", "<leader>ld", ":lua _LAZYDOCKER_TOGGLE()<CR>")
map("n", "<leader>go",":lua _GOQUICKRUN_TOGGLE()<CR>")
-- telescope
map("n", "<leader>ff", ":lua require'telescope.builtin'.find_files{}<CR>")
map("n", "<leader>fr", ":lua require'telescope.builtin'.find_files{no_ignore = true}<CR>")
map("n", "<leader>fg", ":lua require'telescope.builtin'.live_grep{additionals_args={'--no-ignore'}}<CR>")
map("n", "<leader>fs", ":lua require'telescope.builtin'.grep_string()<CR>")
map("n", "<leader>fb", "<CMD>Telescope buffers<CR>")
map("n", "<leader>fh", "<CMD>Telescope help_tags<CR>")

--harpoon


-- lsp
map("n", "<A-f>", vim.lsp.buf.formatting_sync)
map("n", "ƒ", vim.lsp.buf.formatting_sync)
--map("n", "K", vim.lsp.buf.hover)
map("n", "K", "<Cmd>Lspsaga hover_doc<CR>")

map("n", "gd", "<cmd>Telescope lsp_definitions<CR>")
map("n", "gD", "<cmd>Telescope lsp_references<CR>")
map("n", "gi", "<cmd>Telescope lsp_implementations<CR>")
--map("n", "gr", "<cmd>Telescope lsp_references<CR>")
map("n", "gp", "<Cmd>Lspsaga preview_definition<CR>")
map("n", "gr", "<Cmd>Lspsaga rename<CR>")
map("n", "gn", "<cmd>Telescope diagnostics<CR>")
map("n", "gt", ":lua vim.lsp.buf.code_action()<CR>")
-- map("n", "<A-j>",":lua vim.lsp.diagnostic.goto_next()<CR>")
-- map("n", "<A-k>",":lua vim.lsp.diagnostic.goto_prev()<CR>")
map("n", "º",":lua vim.lsp.diagnostic.goto_next()<CR>")
map("n", "∆",":lua vim.lsp.diagnostic.goto_prev()<CR>")
-- clear highlight search
map("n", "<CR>", "<CR> :noh<CR><CR>")

map("n", "<leader>r", ":lua require('nvim-reload').Reload()<CR>:syntax on<CR>")
map("n", "<leader>i", ":LspInfo<CR>")

-- flowers
map("n","<leader><leader>1", ":colorscheme catppuccin_mocha<CR>")
map("n","<leader><leader>2", ":colorscheme tokyonight-moon<CR>")
map("n","<leader><leader>3", ":colorscheme gruvbox<CR>")
map("n","<leader><leader>5", ":colorscheme oxocarbon<CR>")
map("n","<leader><leader>4", ":hi normal ctermbg=none guibg=none<CR>")
