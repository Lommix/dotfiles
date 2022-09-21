vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	--dev
	--
	--use('/home/lommix/Projects/godot.nvim')
	use("lommix/godot.nvim")
	-- packer
	use("wbthomason/packer.nvim")
	-- best lib in town
	use("nvim-lua/plenary.nvim")
	-- colorschemes
	use("gruvbox-community/gruvbox")
	use("folke/tokyonight.nvim")
	use("catppuccin/vim")
	--ui
	-- lsp
	use("mfussenegger/nvim-dap")
	use("neovim/nvim-lspconfig")
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("jose-elias-alvarez/null-ls.nvim")
	use("ray-x/lsp_signature.nvim")
	use("SmiteshP/nvim-navic")
	use("simrat39/symbols-outline.nvim")
	use("b0o/SchemaStore.nvim")
	use("WhoIsSethDaniel/mason-tool-installer.nvim")
	use({ "jayp0521/mason-null-ls.nvim", after = { "null-ls.nvim", "mason.nvim", "mason-tool-installer.nvim" } })
	use("glepnir/lspsaga.nvim")
	use("lvimuser/lsp-inlayhints.nvim")
	-- cmp
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("saadparwaiz1/cmp_luasnip")
	use("vim-autoformat/vim-autoformat")
	use("L3MON4D3/LuaSnip")
	use("nvim-lualine/lualine.nvim")

	use("windwp/nvim-ts-autotag")
	use("windwp/nvim-autopairs")
	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	})
	use("famiu/nvim-reload")
	use("christianchiarulli/lua-dev.nvim")
	use("nvim-telescope/telescope.nvim")
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use("akinsho/toggleterm.nvim")
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use({
		"kyazdani42/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({
				override = {
					zsh = {
						icon = "",
						color = "#428850",
						cterm_color = "65",
						name = "Zsh",
					},
				},
				default = true,
			})
		end,
	})
	use({
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icons
		},
		tag = "nightly", -- optional, updated every week. (see issue #1193)
		config = function()
			vim.g.loaded = 1
			vim.g.loaded_netrwPlugin = 1
			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				view = {
					adaptive_size = true,
				},
				renderer = {
					group_empty = true,
					icons = {
						show = {
							git = true,
						},
					},
				},
				filters = {
					dotfiles = false,
				},
				actions = {
					open_file = {
						quit_on_open = true,
					},
				},
				git = {
					enable = true,
					ignore = false,
				},
			})
		end,
	})
end)
