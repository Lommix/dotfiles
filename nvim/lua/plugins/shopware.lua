local bt = require 'telescope.builtin'
local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local make_entry = require "telescope.make_entry"
local previewers = require "telescope.previewers"

local function get_services()
    local opts = {}
    local find_command = {"rg","--glob","--no-ignore","."}

    results = {"hello","world","lol"}
    pickers.new(opts, {
        prompt_title = "Symfony Container",
        finder = finders.new_table({
            results = results,
        }),
    }):find()
end

return {
    get_services = get_services
}
