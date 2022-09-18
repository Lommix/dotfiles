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
local files = {}
local file_count = 0
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
	local last_parent = parent or nil

	if container.attrs and container.attrs.id and container.tag == "service" then
		local new_entry = {
			id = container.attrs.id,
			container.attrs.id,
			class = container.attrs.class,
			file = file,
			tags = {},
			arguments = {},
		}
	    table.insert(services, new_entry)
        last_parent = new_entry
	end

	-- is tag?
	if parent and container.tag == "tag" and container.attrs then
		table.insert(parent.tags, container.attrs.name)
	end

	-- is argument?
	if parent and container.tag == "argument" and container.attrs.id then
		table.insert(parent.arguments, (container.attrs.type or "") .. " -- " .. (container.attrs.id or ""))
	end
	if container.children then
		for _, child in ipairs(container.children) do
			filter_services(services, child, file, current)
		end
	end
	current = nil
end
-----------------------------------------------------------------------------------
-- read file into local cache
local function read_file_into_cache(filename)
	local doc, _ = xml.parseFile(filename, true)
	filter_services(cached_servies, doc, filename)
end

-----------------------------------------------------------------------------------
-- find all services.xml files
local function build_cache()
	cached_servies = {}
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
		vim.cmd(':let @+="' .. current_selection.id .. '"')
	end
end

local function yank_class(bufnr)
	actions.close(bufnr)
	if not current_selection.class then
		do
			return
		end
	end
	if current_selection then
		vim.cmd(':let @+="' .. current_selection.class .. '"')
	end
end
-----------------------------------------------------------------------------------
-- format preview
function format_preview(entry)
	local content = {}

	table.insert(content, entry.file)
	table.insert(content, "-- service id -- :"..file_count)
	if cached_servies[id] then
		table.insert(content, entry.id)
	end
	table.insert(content, "")
	table.insert(content, "-- class --")
	if entry.class then
		if string.len(entry.class) > 1 then
			table.insert(content, entry.class)
		end
	end
	table.insert(content, "")
	table.insert(content, "-- tags --")
	if entry.tags then
		for _, tag in pairs(entry.tags) do
			if string.len(tag) > 1 then
				table.insert(content, tag)
			end
		end
	end
	table.insert(content, "")
	table.insert(content, "-- arguments --")
	if entry.arguments then
		for _, argument in pairs(entry.arguments) do
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
				results = cached_servies,
				entry_maker = function(entry)
					return {
						ordinal = entry.id,
						display = entry.id,
						value = entry,
					}
				end,
			}),
			---   - `define_preview = function(self, entry, status)` (required)
			previewer = previewers.new_buffer_previewer({
				define_preview = function(self, entry, _)
					current_selection = entry.value
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
