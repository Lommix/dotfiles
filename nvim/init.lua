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
require("lommix.sniprun")
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

vim.cmd[[colorscheme tokyonight-storm]]
-- vim.cmd("colorscheme sobrio_ghost")
-- vim.cmd("syntax on")
--
-- after after
require("lommix.dap")
