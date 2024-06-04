local ts_locals = require("nvim-treesitter.locals")
local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}


---@return string
M.text_node_after_cursor = function()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local bufnr = vim.api.nvim_get_current_buf()
	local parser = ts.get_parser(bufnr)
	local root_tree = parser:parse()[1]
	local root = root_tree:root()
	local cursor_range = { cursor[1] - 1, cursor[2] }
	local node = ts_utils.get_node_at_cursor()
	local timout = 0
	while node do
		-- Check if the node is a text node and if it's after the cursor
		if node:type() == "string" or node:type() == "comment" or node:has_children() == false then
			local node_start, _, node_end, _ = node:range()
			if node_start > cursor_range[1] or (node_start == cursor_range[1] and node_end > cursor_range[2]) then
				return ts_utils.get_node_text(node)[1]
			end
		end
		-- Get the next node in the syntax tree
		node = ts_utils.get_next_node(node)
	end
end


return M
