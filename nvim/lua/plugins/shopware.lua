local bt = require 'telescope.builtin'
local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local make_entry = require "telescope.make_entry"
local previewers = require "telescope.previewers"
local conf = require("telescope.config").values
local plenary = require'plenary.curl'

local function get_services()
    local opts = {}
    opts.additional_args = {'--no-ignore', '-e "id="'}
    opts.glob_pattern = 'services.xml'
    opts.shorten_path = true
    require 'telescope.builtin'.live_grep(opts)
end


-- read services from xml
local function read_services_from_file(filename)
    local services = {}
    local content = vim.fn.readfile(filename)
    for index, line in ipairs(content) do
            for id in string.gmatch(line,"id=\"(.-)\"") do
                table.insert(services, {id = id, xml=filename})
            end
    end
    return services
end

-- find all services.xml files
local function find_all_services()
    local services = {}
    for id, path in ipairs(vim.fn.globpath('.','**/services.xml',true,true)) do
        for id,pair in ipairs(read_services_from_file(path)) do
            services[id] = pair
            --table.insert(services,pair)
        end
    end
    return services
end


local function get_file_path_from_namespace(namespace)
    return "lol"
end

local function get_and_copy_services()
    local opts = {}
    local services = find_all_services()

    print(vim.inspect(services))
    pickers
    .new(opts, {
        prompt_title = "symfony services",
        finder = finders.new_table {
            results = services,
            entry_maker = function(service)
                return make_entry.set_default_entry_mt({
                    ordinal = service.id,
                    display = service.id,
                    path = service.xml,
                }, opts)
            end,
        },
        previewer = previewers.new_buffer_previewer({
            define_preview = function(self, entry, status)
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 1, true, {entry.path, entry.display})
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            return true
        end,
    })
    :find()
end


return {
    get_services = get_services,
    get_and_copy_services = get_and_copy_services
}
