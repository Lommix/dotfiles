return {
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"plenary",
		},
		config = function()
			local function formattedName(_, path)
				local tail = vim.fs.basename(path)

				local parent = vim.fs.dirname(path)
				if parent == "." then
					return tail
				end
				return string.format("%s\t\t%s", tail, parent)
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "TelescopeResults",
				callback = function(ctx)
					vim.api.nvim_buf_call(ctx.buf, function()
						vim.fn.matchadd("TelescopeParent", "\t\t.*$")
						vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
					end)
				end,
			})

			require("telescope").setup({
				fzf = {
					fuzzy = false, -- false will only do exact matching
					override_generic_sorter = false, -- override the generic sorter
					override_file_sorter = false, -- override the file sorter
					case_mode = "ignore_case", -- or "ignore_case" or "respect_case"
				},
				defaults = {
					path_display = formattedName,
					file_ignore_patterns = { ".png", ".jpg", ".import", ".jepg", ".aseprite", ".glb", ".bak" },
				},
			})
		end,
		after = {
			"nvim-lspconfig",
			"nvim-treesitter",
		},
		keys = {
			{ "<leader>ff", ":Telescope find_files find_command=rg,--ignore,--files prompt_prefix=🔍<CR>" },
			{ "<leader>fg", ":Telescope live_grep find_command=rg,--ignore,--files prompt_prefix=🔍<CR>" },
			{
				"<leader>fs",
				function()
					require("telescope.builtin").grep_string({
						additional_args = function(args)
							return vim.list_extend(args, { "--hidden", "--no-ignore" })
						end,
					})
				end,
				mode = "n",
			},
			{
				"<leader>fv",
				function()
					require("telescope.builtin").find_files({
						cwd = "./vendor",
					})
				end,
			},
			{ "<leader>fb", "<CMD>Telescope buffers<CR>" },
			{ "<leader>fh", "<CMD>Telescope help_tags<CR>" },
			{ "<leader>fc", "<CMD>Telescope colorscheme<CR>" },
			{
				"<leader>fd",
				function()
					require("telescope.builtin").find_files({
						hidden = true,
						no_ignore = true,
						search_dirs = { "~/.config/nvim" },
					})
				end,
			},
			{
				"<leader>FF",
				function()
					require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
				end,
			},
			{
				"<leader>fG",
				function()
					require("telescope.builtin").live_grep({
						additional_args = function(args)
							return vim.list_extend(args, { "--hidden", "--no-ignore" })
						end,
					})
				end,
			},
			{
				"<leader>FG",
				function()
					local filetype = vim.fn.input("Filetype: ")
					require("telescope.builtin").live_grep({
						type_filter = filetype,
						additional_args = function(args)
							return vim.list_extend(args, { "--hidden", "--no-ignore" })
						end,
					})
				end,
			},
			{
				mode = "v",
				"<leader>fs",
				function()
					require("telescope.builtin").grep_string({
						additional_args = function(args)
							return vim.list_extend(args, { "--hidden", "--no-ignore" })
						end,
					})
				end,
			},
		},
	},
}
