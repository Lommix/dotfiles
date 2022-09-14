local bt = require 'telescope.builtin'
local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local make_entry = require "telescope.make_entry"
local previewers = require "telescope.previewers"
local conf = require("telescope.config").values
local actions = require'telescope.actions'


local terminal = require'toggleterm.terminal'.Terminal:new({
    dir = vim.fn.getcwd()
})

local function sw_kl_tmp()
    if not terminal:is_open() then
        terminal:toggle()
    end
    terminal:clear()
    terminal:send('ddev . bin/console netzd:import:tracking')
end

local function sw_cache_clear()
    if not terminal:is_open() then
        terminal:toggle()
    end
    terminal:clear()
    terminal:send('ddev . bin/console sw:cache:clear')
end

local function get_services()
    local opts = {}
    opts.prompt_title = "Search Service Files"
    opts.additional_args = {'--no-ignore', '-e "id="'}
    opts.glob_pattern = 'services.xml'
    opts.shorten_path = true
    require 'telescope.builtin'.live_grep(opts)
end

-- read services from xml
local function read_services_from_file(filename)
    local parser = require'plugins.xmlparser'
    local doc,_  = parser.parseFile(filename, true)
    local services = {}
    local classes = doc.children[1].children[1].children
    for _, service in pairs(classes) do
        if service.attrs.id and service.attrs.class then
            table.insert(services, service.attrs)
        end
    end
    return services
end

-- find all services.xml files
local function find_all_services()
    local services = {}
    local files = vim.fn.globpath('.','**/services.xml', true, true)
    for _, path in pairs(files) do
        local data = read_services_from_file(path)
        for _,service in pairs(data) do
            services[service.id] = service
        end
    end
    local tmp = {}
    for _,s in pairs(services) do
        table.insert(tmp, s)
    end
    return tmp
end

local selection = nil
local function select_yank_and_exit(bufnr)
    actions.close(bufnr)
    if selection then
        vim.cmd(':let @+="' .. selection .. '"')
    end
end

local function get_and_copy_services()
    local opts = {}
    local services = find_all_services()
    pickers
    .new(opts, {
        prompt_title = 'shopware service selector',
        finder = finders.new_table {
            results = services,
            entry_maker = function(service)
                return make_entry.set_default_entry_mt({
                    ordinal = service.id,
                    display = service.id,
                    path = service.class,
                }, opts)
            end,
        },
        previewer = previewers.new_buffer_previewer({
            define_preview = function(self, entry, _)
                selection = entry.display
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 1, true, {entry.path, entry.display})
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(_, map)
            map("i", "<CR>", select_yank_and_exit)
            return true
        end,
    })
    :find()
end


vim.api.nvim_create_user_command('SwService', get_and_copy_services, {})
vim.api.nvim_create_user_command('SwEvents', get_and_copy_services, {})
vim.api.nvim_create_user_command('SwEvents', get_and_copy_services, {})

return {
    get_services = get_services,
    get_and_copy_services = get_and_copy_services,
    sw_cache_clear = sw_cache_clear,
    sw_kl_tmp = sw_kl_tmp,
}
