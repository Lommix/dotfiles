vim.g.codeium_disable_bindings = true
vim.g.codeium_enabled = false


vim.keymap.set("i", "<C-a>", function()
	return vim.fn["codeium#Accept"]()
end, { expr = true })


vim.g.codeium_filetypes = {
	sh = false,
	bash = false,
}

-- enable by default for filetypes
vim.api.nvim_create_autocmd({"BufEnter"}, {
	pattern = {"*.php","*.lua","*.js","*.ts","*.svelte", "*.rs"},
	command = "CodeiumEnable",
})
