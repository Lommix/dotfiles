local ok, hc = pcall(require, "nvim-highlight-colors")
if not ok then
	return
end
hc.setup({
	enable_tailwind = true,
})
