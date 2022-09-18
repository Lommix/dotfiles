local M = {}

local a = vim.api

local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")

-----------------------------------------------------------------------------------
local xml = require("lommix.scripts.xmlparser")
local cached_servies = {}
local current_selection = nil
local preview_window = nil
-----------------------------------------------------------------------------------
M.get_services = function()
	local opts = {}
	opts.prompt_title = "Search Service Files"
	opts.additional_args = { "--no-ignore", '-e "id="' }
	opts.glob_pattern = "services.xml"
	opts.shorten_path = true
	require("telescope.builtin").live_grep(opts)
end

-- container = {
--      attrs = { id= .. class= ..},
--      children ={container, container ...}
-- }
-----------------------------------------------------------------------------------
-- recursive build services table
local function filter_services(services, container, file, parent)
	local current = parent or nil

	if container.attrs and container.attrs.id and container.tag == "service" then
		current = string.gsub(container.attrs.id, "\n", "")
		if not services[current] then
			services[container.attrs.id] = {
				id = container.attrs.id,
				container.attrs.id,
				class = string.gsub(container.attrs.class or "", "\n", ""),
				file = file,
				tags = {},
				arguments = {},
			}
		end
	end

	-- is tag?
	if parent and container.tag == "tag" and container.attrs then
		table.insert(services[parent].tags, container.attrs.name)
	end

	-- is argument?
	if parent and container.tag == "argument" and container.attrs.id then
		table.insert(services[parent].arguments, (container.attrs.type or "") .. " -- " .. (container.attrs.id or ""))
	end
	if container.children then
		for _, child in ipairs(container.children) do
			filter_services(services, child, file, current)
		end
	end
	local current = nil
end
-----------------------------------------------------------------------------------
-- read file into local cache
local function read_file_into_cache(filename)
	local doc, _ = xml.parseFile(filename, true)
	cached_servies = {}
	filter_services(cached_servies, doc, file)
end

-----------------------------------------------------------------------------------
-- find all services.xml files
local function build_cache()
	local services = {}
	local files = vim.fn.globpath(".", "**/services.xml", true, true)
	for _, path in pairs(files) do
		local data = read_file_into_cache(path)
	end
end

-----------------------------------------------------------------------------------
-- action
local function yank_id(bufnr)
	actions.close(bufnr)
	if current_selection then
		vim.cmd(':let @+="' .. cached_servies[current_selection].id .. '"')
	end
end

local function yank_class(bufnr)
	actions.close(bufnr)
	if not cached_servies[current_selection].class then
		do
			return
		end
	end
	if current_selection then
		vim.cmd(':let @+="' .. cached_servies[current_selection].class .. '"')
	end
end
-----------------------------------------------------------------------------------
-- format preview
function format_preview(id)
	local content = {}

	table.insert(content, "-- service id --")
	if cached_servies[id] then
		table.insert(content, cached_servies[id].id)
	end
	table.insert(content, "")
	table.insert(content, "-- class --")
	if cached_servies[id].class then
		if string.len(cached_servies[id].class) > 1 then
			table.insert(content, cached_servies[id].class)
		end
	end
	table.insert(content, "")
	table.insert(content, "-- tags --")
	if cached_servies[id].tags then
		for _, tag in pairs(cached_servies[id].tags) do
			if string.len(tag) > 1 then
				table.insert(content, tag)
			end
		end
	end
	table.insert(content, "")
	table.insert(content, "-- arguments --")
	if cached_servies[id].arguments then
		for _, argument in pairs(cached_servies[id].arguments) do
			table.insert(content, argument)
		end
	end
	return content
end

M.service_finder = function()
	local opts = {}
	build_cache()
	pickers
		.new(opts, {
			prompt_title = "shopware service selector",
			finder = finders.new_table({
				results = vim.tbl_keys(cached_servies),
				entry_maker = function(id)
					return {
						ordinal = id,
						display = id,
						value = id,
					}
				end,
			}),
			---   - `define_preview = function(self, entry, status)` (required)
			previewer = previewers.new_buffer_previewer({
				define_preview = function(self, entry, _)
					current_selection = entry.value
					preview_window = a.nvim_get_current_buf()
					a.nvim_buf_set_lines(self.state.bufnr, 0, 1, true, format_preview(entry.value))
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(_, map)
				map("i", "<CR>", yank_id)
				map("i", "<A-CR>", yank_class)
				return true
			end,
		})
		:find()
end

return M
