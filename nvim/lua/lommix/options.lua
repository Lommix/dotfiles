local g = vim.g
local o = vim.o
local opt = vim.opt
local api = vim.api

-- general
o.splitright = true
o.splitbelow = true
o.showmatch = true
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true
o.tabstop = 4
o.softtabstop = 4
--o.expandtab = true
o.wrap = false
o.hlsearch = false
o.shiftwidth = 4
o.autoindent = true
o.smartindent = true
o.number = true
o.relativenumber = true
o.mouse = a
o.cursorline = true
o.wildmenu = true
-- opt.foldmethod = "marker"
o.wildmode = "longest:full,full"
o.listchars = "trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂"
o.clipboard = "unnamedplus"
o.swapfile = false
o.undofile = true
o.nuw = 6
opt.fillchars = { eob = " " }
opt.mouse = "a"
opt.equalalways = true
o.termguicolors = true
opt.list = true
-- opt.listchars:append "space:⋅"
opt.listchars:append("eol:↴")
vim.g.gitblame_enabled = 0
