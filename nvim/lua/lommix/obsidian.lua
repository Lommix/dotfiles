local ok, obs = pcall(require, "obsidian")

if not ok then
	return
end

obs.setup({
	dir = "~/Documents/obsidian/Dev",
})
