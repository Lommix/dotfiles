local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_states = require("telescope.actions.state")
local Job = require("plenary.job")

vim.keymap.set("n", "<leader>as", function()
	pickers
		:new({
			finder = finders.new_oneshot_job({ "find", ".", "-type", "f", "-name", "*.aseprite" }, {}),
			sorter = conf.generic_sorter(),
			previewer = false,
			file_ignore_patterns = {},
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_states.get_selected_entry()[1]
					actions.close(prompt_bufnr)
					Job:new({
						command = "aseprite",
						args = { selection },
					}):start()
				end)
				return true
			end,
		})
		:find()
end)
