local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end

-- split movement : linux
map("n", "<A-h>", "<C-w>h")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-l>", "<C-w>l")

-- remaps
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u", "<C-u>zz")

-- marks
for i = 97, 122 do
	local lower = string.char(i)
	local upper = string.upper(lower)
	map("n", "m" .. lower, "m" .. upper)
	map("n", "." .. lower, "'" .. upper)
end

-- split
map("n", "<leader>sh", "<C-w>s")
map("n", "<leader>sv", "<C-w>v")
map("n", "<leader>se", "<C-w>=")
map("n", "<leader>q", ":close<CR>")

-- util
map("n", "<leader>+", "<C-a>")
map("n", "<leader>-", "<C-x>")
map("n", "x", '"_x')
map("n", "<leader>e", ":Oil --float<CR>")

-- resize
map("n", "<C-Right>", "<C-w><")
map("n", "<C-Left>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")

map("n", "<leader>e", ":Oil<CR>")

-- GIT
map("n", "<leader>gg", ":Git<CR>")
map("n", "<leader>gp", ":Git push<CR>")

-- DB
map("n", "<leader>db", ":DBUIToggle<CR>")

-- lsp
map("n", "<leader>i", ":LspInfo<CR>")
map("n", "<leader>fa", ":Format<CR>")

map("n", "gr", ":IncRename ")

-- clear highlight search
map("n", "<CR>", "<CR> :noh<CR><CR>")

-- flowers
map("n", "<leader><leader>1", ":colorscheme catppuccin_mocha<CR>")
map("n", "<leader><leader>2", ":colorscheme tokyonight-moon<CR>")
map("n", "<leader><leader>3", ":colorscheme gruvbox<CR>")
map("n", "<leader><leader>5", ":colorscheme nightfly<CR>")
map("n", "<leader><leader>6", ":colorscheme kanagawa<CR>")
map("n", "<leader><leader>b", ":hi normal ctermbg=none guibg=none<CR>")

-- vim.api.nvim_create_autocmd({ "TextChangedI" }, {
-- 	pattern = { "*" },
-- 	callback = function(ev)
--         local clients = vim.lsp.get_clients()
--         for _, client in pairs(clients) do
--             if client.resolved_capabilities.signature_help then
--                 vim.lsp.buf.signature_help()
--                 break -- Only call signature_help once if multiple clients support it
--             end
--         end
-- 	end
-- })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }

		vim.keymap.set("n", "<C-k>", vim.diagnostic.open_float, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, opts)
		local ok, preview = pcall(require, "actions-preview")



		if ok then
			vim.keymap.set("n", "gt", preview.code_actions, opts)
		else
			vim.keymap.set("n", "gt", vim.lsp.buf.code_action, opts)
		end

		-- vim.keymap.set("n", "gt", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gR", vim.lsp.buf.references, opts)

		map("n", "<leader>fa", ":Format<CR>")

		map("n", "gn", function()
			require("trouble").toggle()
		end)
		map("n", "gR", "<cmd>Telescope lsp_references<CR>")
	end,
})

---------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------
-- general purpose build
map("n", "<leader>b", function()
	run_shell("build.sh")
end)
---------------------------------------------------------------------------------
-- general purpose run
map("n", "<leader>r", function()
	run_shell("run.sh")
end)
