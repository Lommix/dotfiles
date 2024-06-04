local M = {}

---@type string
local log_file = "~/.log/nvim/nvim.log"

---@param msg string
M.log = function(msg)
	local fp = io.open(log_file, "a")
	if fp then
		local str = string.format("[%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), msg)
		fp:write(str)
		fp:close()
	end
end

M.debug_log = function(var)
	M.log(vim.inspect(var))
end

return M
