vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	-- packer
	use("wbthomason/packer.nvim")
	-- libs
	use("nvim-lua/plenary.nvim")
	-- colorschemes
	use("gruvbox-community/gruvbox")
	use("folke/tokyonight.nvim")
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
    use { "jayp0521/mason-null-ls.nvim", after = { "null-ls.nvim", "mason.nvim", }, }
	-- cmp
	use({
		"hrsh7th/nvim-cmp",
		config = function()
			require("plugins.cmp")
		end,
	})
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("saadparwaiz1/cmp_luasnip")
	use("vim-autoformat/vim-autoformat")
	use("L3MON4D3/LuaSnip")
	use("habamax/vim-godot")
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	})
	use("famiu/nvim-reload")
	use("christianchiarulli/lua-dev.nvim")

	use({
		"nvim-telescope/telescope.nvim",
		config = function()
			require("plugins.telescope-config")
		end,
	})
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup()
		end,
	})
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
				},
				filters = {
					dotfiles = true,
				},
				actions = {
					open_file = {
						quit_on_open = true,
					},
				},
			})
		end,
	})
end)
