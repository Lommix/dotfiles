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
        if not string.find(line, "argument") then
            for id, class in string.gmatch(line,"id=\"(.-)\" class=\"(.-)\"") do
                table.insert(services, {id = id, class=class, xml=filename})
            end
        end
    end
    return services
end

-- find all services.xml files
local function find_all_services()
    local services = {}
    for id, path in ipairs(vim.fn.globpath('.','**/services.xml',true,true)) do
        for _, service in ipairs(read_services_from_file(path)) do
            table.insert(services, service)
        end
    end
    return services
end


local function get_file_path_from_namespace(namespace)
    return "123"
end

local function get_and_copy_services()
    local opts = {}
    local services = find_all_services()

    local test = get_file_path_from_namespace("")
    --pickers
    --.new(opts, {
    --    prompt_title = "symfony services",
    --    finder = finders.new_table {
    --        results = services,
    --        entry_maker = function(service)
    --            return make_entry.set_default_entry_mt({
    --                ordinal = service.id,
    --                display = service.id,
    --                path = service.xml,
    --                class = service.class,
    --                filename = get_file_path_from_namespace(service.class)
    --            }, opts)
    --        end,
    --    },
    --    previewer = previewers.new_buffer_previewer({
    --        define_preview = function(self, entry, status)
    --            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 1, true, {entry.path, entry.display, entry.class, entry.filename})
    --        end,
    --    }),
    --    sorter = conf.generic_sorter(opts),
    --    attach_mappings = function(prompt_bufnr)
    --        return true
    --    end,
    --})
    --:find()
end


return {
    get_services = get_services,
    get_and_copy_services = get_and_copy_services
}
