require("lommix.plugins")
require("lommix.options")
require("lommix.keybinds")
require("lommix.auto")
require("lommix.lsp")
require("lommix.reloader")
require("lommix.lsp-inlayhints")
require'lommix.lspsage'
require("lommix.toggleterm")
require("lommix.lualine")
require("lommix.autotag")
require("lommix.autopair")
require("lommix.treesitter")
require("lommix.globals")
require("lommix.telescope")
require("lommix.cmp")
require("lommix.scripts")
require("lommix.godot")
require("lommix.rest")
require("lommix.harpoon")
require("lommix.comment")
require("lommix.highlight-colors")
require("lommix.rust-tools")
-- after plugins
require("lommix.luasnip")
require("lommix.dap")

vim.cmd("syntax on")
vim.cmd("colorscheme gruvbox")
vim.cmd("hi normal ctermbg=none guibg=none")
