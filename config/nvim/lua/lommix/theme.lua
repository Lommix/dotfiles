local file_path = "/home/lommix/.cache/nvim/current_color"
-----------------------------------
--- load current colors
local load = function()
	local f, err = io.open(file_path, "r")
	if err ~= nil then
		return
	end

	if f == nil then
		return
	end

	local theme = f:read("*a")
	vim.cmd("colorscheme " .. theme)
	f:close()
end
load()
-----------------------------------
--- save on change
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
	callback = function()
		local f, err = io.open(file_path, "w+")
		if err ~= nil then
			print(err)
			return
		end

		if f == nil then
			print(err)
			return
		end
		f:write(vim.g.colors_name)
		f:close()
	end,
})
