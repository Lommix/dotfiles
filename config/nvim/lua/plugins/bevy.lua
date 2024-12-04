return {
	"lommix/bevy_inspector.nvim",
	dir = "~/Projects/nvim_plugins/bevy_inspector.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("bevy_inspector").setup()
		vim.keymap.set("n", "<leader>z", ":BevyInspect<Cr>", { silent = true })
		vim.keymap.set("n", "<leader>u", ":BevyInspectNamed<Cr>", { silent = true })
		vim.keymap.set("n", "<leader>i", ":BevyInspectQuery<Cr>", { silent = true })
	end,
}
