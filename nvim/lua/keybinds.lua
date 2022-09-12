local function map(m, k, v)
    vim.keymap.set(m, k, v, { silent = true })
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- split movement : linux
map('n','<A-h>','<C-w>h')
map('n','<A-j>','<C-w>j')
map('n','<A-k>','<C-w>k')
map('n','<A-l>','<C-w>l')

-- split movement : mac
map('n','ª','<C-w>h')
map('n','º','<C-w>j')
map('n','∆','<C-w>k')
map('n','@','<C-w>l')

-- split
map('n','<leader>s','<CMD>split<CR>')
map('n','<leader>v','<CMD>vsplit<CR>')
map('n','<leader>q','<CMD>close<CR>')
map('n','<leader>e','<CMD>vsplit<BAR>:Ex<CR>')

map('n','<leader>j',':resize -2<CR>')
map('n','<leader>k',':resize +2<CR>')
map('n','<leader>l',':vertical resize -2<CR>')
map('n','<leader>h',':vertical resize +2<CR>')

-- telescope
map('n','<leader>ff','<CMD>Telescope find_files<CR>')
map('n','<leader>fb','<CMD>Telescope buffers<CR>')
map('n','<leader>f','<CMD>Autoformat<CR>')
map('n','<leader>b','<CMD>Ex<CR>')

-- lsp
map('n','K',':lua vim.lsp.buf.hover()<CR>')
map('n','gd',':lua vim.lsp.buf.definition()<CR>')
map('n','gD',':lua vim.lsp.buf.declaration()<CR>')
map('n','gr',':lua vim.lsp.buf.references()<CR>')
map('n','gi',':lua vim.lsp.buf.implementation()<CR>')

-- clear highlight search
map('n','<CR>','<CR> :noh<CR><CR>')

--debug
map('n', '<leader>r',':luafile %<CR>')
local godot = require('plugins.godot')
map('n','<leader>b',godot.debug)
map('n','<leader>d',godot.debug_at_cursor)
