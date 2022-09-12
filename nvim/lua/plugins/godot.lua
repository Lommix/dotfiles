-- must have godot executeable in globals
local Terminal = require('toggleterm.terminal').Terminal
local godotTerm = Terminal:new({
    dir = vim.fn.getcwd(),
})

-- starts debug session with breakpoint at current cursor location
local function debug_at_cursor()
    local breapoint = "res://" .. vim.fn.expand('%') .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
    if not godotTerm:is_open() then
        godotTerm:toggle()
    end
    godotTerm:clear()
    godotTerm:send('godot -d -b ' .. breapoint)
end

-- starts debug session, breaks on crash
local function debug()
    if not godotTerm:is_open() then
        godotTerm:toggle()
    end
    godotTerm:clear()
    godotTerm:send('godot -d')
end


local function print_stack(t)
    godotTerm:send('mv')
    godotTerm:send('lv')
end



return {
    debug_at_cursor = debug_at_cursor,
    debug = debug
}
