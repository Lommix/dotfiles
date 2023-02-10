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
map("n", "<leader>sh", "<C-w>s")
map("n", "<leader>sv", "<C-w>v")
map("n", "<leader>se", "<C-w>=")
map("n", "<leader>q", ":close<CR>")

-- tabs
map("n", "<leader>to", ":tabnew<CR>")
map("n", "<leader>tx", ":tabclose<CR>")
map("n", "<leader>tn", ":tabn<CR>")
map("n", "<leader>tp", ":tabp<CR>")

-- util
map("n", "<leader>+", "<C-a>")
map("n", "<leader>-", "<C-x>")
map("n", "x", '"_x')
map("n", "<leader>e", ":NvimTreeFindFileToggle<CR>:NvimTreeFocus<CR>")

-- resize
map("n", "<C-Right>", "<C-w><")
map("n", "<C-Left>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")

-- git
map("n", "<leader>lg", ":lua _LAZYGIT_TOGGLE()<CR>")
map("n", "<leader>ld", ":lua _LAZYDOCKER_TOGGLE()<CR>")
map("n", "<leader>go",":lua _GOQUICKRUN_TOGGLE()<CR>")

-- telescope
map("n", "<leader>ff", ":lua require'telescope.builtin'.find_files{}<CR>")
map("n", "<leader>fr", ":lua require'telescope.builtin'.find_files{no_ignore = true}<CR>")
map("n", "<leader>fg", ":lua require'telescope.builtin'.live_grep{additional_args={'--no-ignore'}}<CR>")
map("n", "<leader>fs", ":lua require'telescope.builtin'.grep_string()<CR>")
map("n", "<leader>fb", "<CMD>Telescope buffers<CR>")
map("n", "<leader>fh", "<CMD>Telescope help_tags<CR>")

--harpoon


-- lsp
map("n", "<A-f>", ":lua vim.lsp.buf.format()<CR>")
map("n", "ƒ", ":lua vim.lsp.buf.format()<CR>")
--map("n", "K", vim.lsp.buf.hover)
map("n", "K", "<Cmd>Lspsaga hover_doc<CR>")

map("n", "gd", "<cmd>Telescope lsp_definitions<CR>")
map("n", "gD", "<cmd>Telescope lsp_references<CR>")
map("n", "gi", "<cmd>Telescope lsp_implementations<CR>")
--map("n", "gr", "<cmd>Telescope lsp_references<CR>")
map("n", "gp", "<Cmd>Lspsaga peek_definition<CR>")
map("n", "gr", "<Cmd>Lspsaga rename<CR>")
map("n", "gn", "<cmd>Telescope diagnostics<CR>")
map("n", "gt", ":lua vim.lsp.buf.code_action()<CR>")
map("n", "<C-k>",":lua vim.diagnostic.open_float()<CR>")
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
map("n","<leader><leader>5", ":colorscheme nightfly<CR>")
map("n","<leader><leader>6", ":colorscheme kanagawa<CR>")
map("n","<leader><leader>b", ":hi normal ctermbg=none guibg=none<CR>")
