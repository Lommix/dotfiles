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

-- term
map("t", "<Esc>", "<C-\\><C-n>")

-- util
map("n", "<leader>+", "<C-a>")
map("n", "<leader>-", "<C-x>")
map("n", "x", '"_x')
map("n", "<leader>e", ":Oil --float<CR>")

-- load curent file path into yank register
map("n", "<leader>y", function()
	vim.cmd(':let @+="' .. vim.fn.expand("%:p") .. '"')
end)

-- resize
map("n", "<C-Right>", "<C-w><")
map("n", "<C-Left>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")

-- GIT
map("n", "<leader>gg", ":Git<CR>")
map("n", "<leader>gp", ":Git push<CR>")

-- DB
map("n", "<leader>db", ":DBUIToggle<CR>")

-- telescope
map("n", "<leader>ff", ":Telescope find_files find_command=rg,--ignore,--files prompt_prefix=🔍<CR>")
map("n", "<leader>fg", ":Telescope live_grep find_command=rg,--ignore,--files prompt_prefix=🔍<CR>")
map("n", "<leader>fs", ":Telescope grep_string find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍<CR>")
map("n", "<leader>fb", "<CMD>Telescope buffers<CR>")
map("n", "<leader>fh", "<CMD>Telescope help_tags<CR>")
map("n", "<leader>fc", "<CMD>Telescope colorscheme<CR>")

map("n", "<leader>FF", function()
	require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
end)

map("n", "<leader>fG", function()
	require("telescope.builtin").live_grep({
		additional_args = function(args)
			return vim.list_extend(args, { "--hidden", "--no-ignore" })
		end,
	})
end)

map("n", "<leader>fs", function()
	require("telescope.builtin").grep_string({
		additional_args = function(args)
			return vim.list_extend(args, { "--hidden", "--no-ignore" })
		end,
	})
end)

map("v", "<leader>fs", function()
	require("telescope.builtin").grep_string({
		additional_args = function(args)
			return vim.list_extend(args, { "--hidden", "--no-ignore" })
		end,
	})
end)

map("n", "<leader>FG", function()
	local filetype = vim.fn.input("Filetype: ")
	require("telescope.builtin").live_grep({
		type_filter = filetype,
		additional_args = function(args)
			return vim.list_extend(args, { "--hidden", "--no-ignore" })
		end,
	})
end)

-- lsp
map("n", "<leader>i", ":LspInfo<CR>")
map("n", "<leader>t", ":ChatGPT<CR>")
map("n", "<leader>fa", ":Format<CR>")

map("i", "<C-g>", function()
	P("copilot!")
	require("copilot.suggestion").accept()
end);

local opts = { silent = true }

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "<C-k>", vim.diagnostic.open_float, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		-- vim.keymap.set("n", "gt", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gt", ":CodeActionMenu<CR>", opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gR", vim.lsp.buf.references, opts)
		-- map("n", "<leader>fa", ":lua vim.lsp.buf.format()<CR>")
		map("n", "GN", function()
			require("telescope.builtin").diagnostics({})
		end)
		map("n", "gn", function()
			require("telescope.builtin").diagnostics({
				severity = vim.diagnostic.severity.ERROR,
			})
		end)
		map("n", "gR", "<cmd>Telescope lsp_references<CR>")
	end,
})

map("n", "gr", ":IncRename ")
-- clear highlight search
map("n", "<CR>", "<CR> :noh<CR><CR>")
map("n", "<leader>R", ":lua require('nvim-reload').Reload()<CR>:syntax on<CR>")

-- flowers
map("n", "<leader><leader>1", ":colorscheme catppuccin_mocha<CR>")
map("n", "<leader><leader>2", ":colorscheme tokyonight-moon<CR>")
map("n", "<leader><leader>3", ":colorscheme gruvbox<CR>")
map("n", "<leader><leader>5", ":colorscheme nightfly<CR>")
map("n", "<leader><leader>6", ":colorscheme kanagawa<CR>")
map("n", "<leader><leader>b", ":hi normal ctermbg=none guibg=none<CR>")

-- rust
map("n", "<leader>ta", ":!cargo test -- --nocapture<CR>")

-- super usefull yank, execute and paste result for scripts
map("n", "<leader>p", function()
	local cmd = vim.fn.getreg('"')
	local output = vim.fn.system(cmd)

	output = output:gsub("[\t]+", "") -- Remove tabs
	output = output:gsub("[\x1b]+%[.-m", "") -- Remove ANSI escape sequences

	local current_line, current_col = unpack(vim.api.nvim_win_get_cursor(0))
	local lines = {}

	for line in output:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, lines)
end)

-- run shell script
local function run_shell(filename)
	local file = vim.fn.findfile(filename, ".;")
	if file == "" then
		P("file not found: " .. filename)
		return
	else
		vim.cmd(":term ./" .. file)
	end
end

-- general purpose build
map("n", "<leader>b", function()
	run_shell("build.sh")
end)

-- general purpose run
map("n", "<leader>r", function()
	run_shell("run.sh")
end)

-- project notes
local buffer = vim.api.nvim_create_buf(false, true)
local function open_notes()
	local dir = "~/.quicky"
	local path = dir .. "/" .. string.gsub(vim.fn.getcwd(), "/", "") .. ".md"

	if not vim.fn.filereadable(path) == true then
		print("cannot open " .. path)
		return
	end

	vim.api.nvim_open_win(buffer, true, {
		height = vim.api.nvim_get_option("lines") - 10,
		width = vim.api.nvim_get_option("columns") - 10,
		border = "double",
		relative = "editor",
		col = 5,
		row = 5,
	})

	vim.api.nvim_buf_call(buffer, function()
		vim.cmd("e " .. path)
	end)

	vim.api.nvim_buf_set_keymap(buffer, "n", "q", ":wq<CR>", { silent = true })
end

map("n", "<leader>n", open_notes)
