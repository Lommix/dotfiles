local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end

map("t", "<esc>", [[<C-\><C-n>]])

-- lang
map("n", "<leader>sde", ":set spell<Cr>:set spelllang=de<CR>")
map("n", "<leader>sen", ":set spell<Cr>:set spelllang=en<CR>")

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
-- map("n", "<C-d>", "<C-d>zz")
-- map("n", "<C-u", "<C-u>zz")

-- quickfix
map("n", "<C-g>", ":cprevious<CR>")
map("n", "<C-h>", ":cnext<CR>")
map("n", "<C-q>", ":copen<CR>")

-- always global mark
-- for i = 97, 122 do
-- 	local lower = string.char(i)
-- 	local upper = string.upper(lower)
-- 	map("n", "m" .. lower, "m" .. upper)
-- 	map("n", "." .. lower, "'" .. upper)
-- end

-- split
map("n", "<leader>sh", "<C-w>s")
map("n", "<leader>sv", "<C-w>v")
map("n", "<leader>se", "<C-w>=")
map("n", "<leader>q", ":close<CR>")
map("n", "<leader>o", ":vsplit term:// blitzdenk chat openai<CR>:startinsert<CR>")

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

-- MISC
-- map("n", "<CR>", "<CR> :noh<CR><CR>")
map("n", "<leader><leader>b", ":hi normal ctermbg=none guibg=none<CR>")

---------------------------------------------------------------------------------
-- lsp keys
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }

		vim.keymap.set("n", "<leader>fa", ":Format<CR>", opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.rename, opts)

		vim.keymap.set("n", "<C-k>", vim.diagnostic.open_float, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, opts)

		vim.keymap.set("n", "<c-n>", function()
			vim.diagnostic.get_next({
				severity = vim.diagnostic.severity.ERROR,
			})
		end, opts)

		local ok, preview = pcall(require, "actions-preview")

		if ok then
			vim.keymap.set("n", "gt", preview.code_actions, opts)
		else
			vim.keymap.set("n", "gt", vim.lsp.buf.code_action, opts)
		end

		vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gR", vim.lsp.buf.references, opts)

		map("n", "<leader>fa", ":Format<CR>")
		map("n", "gR", "<cmd>Telescope lsp_references<CR>")
	end,
})

---------------------------------------------------------------------------------

local function close_any_terminal()
	for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf_id].buftype == "terminal" then
			vim.cmd("bwipeout " .. buf_id) -- Close the terminal buffer
		end
	end
end

-- run shell script
local function run_shell(filename)
	close_any_terminal()
	local file = vim.fn.findfile(filename, ".;")
	if file == "" then
		local header = { "#!/bin/bash" }
		vim.fn.writefile(header, filename)
		vim.fn.system("chmod +x " .. filename)
		vim.cmd("e " .. filename)
		return
	else
		vim.cmd("14split term://./" .. file)
		vim.cmd("normal! G")
	end
end

-- watch compiler output
local ev = vim.uv.new_fs_event()
vim.uv.fs_event_start(ev, ".compile_errors", {}, function()
	vim.schedule(function()
		vim.cmd("silent! cfile .compile_errors")
	end)
end)

---------------------------------------------------------------------------------
-- general purpose build
map("n", "<leader>b", function()
	vim.cmd("make build")
end)
---------------------------------------------------------------------------------
-- general purpose run
map("n", "<leader>r", function()
	-- run_shell_qfix("run.sh")
	vim.cmd("make run")
end)
---------------------------------------------------------------------------------
-- general purpose test
map("n", "<leader>p", function()
	-- run_shell_qfix("test.sh")
	vim.cmd("make test")
end)

-- find path
map("n", "<leader>fp", function()
	local pwd = vim.fn.expand("%r")
	print(pwd)
end)
