local g = vim.g
local o = vim.o
local opt = vim.opt
local api = vim.api

-- general
o.showmatch =true
o.ignorecase =true
o.smartcase =true
o.hlsearch = true
o.incsearch = true
o.tabstop = 4
o.softtabstop = 4
o.expandtab  =  true
o.shiftwidth = 4
o.autoindent = true
o.number = true
o.relativenumber=true
o.mouse=a
o.cursorline=true
o.ttyfast=true
o.wildmenu = true
o.wildmode='longest:full,full'
o.backupdir='~/.cache/vim'
o.listchars='trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂'
o.clipboard='unnamedplus'
o.swapfile = false
o.undofile = true
g.nohlsearch=true
opt.mouse = 'a'

require('plugins')
require('keybinds')
require('auto')

vim.cmd("colorscheme gruvbox")
vim.cmd("hi normal ctermbg=none")
vim.cmd("syntax on")
vim.cmd("nohlsearch")