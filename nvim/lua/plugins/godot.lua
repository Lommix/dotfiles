-- must have godot executeable in globals
local Terminal = require('toggleterm.terminal').Terminal

-- starts debug session with breakpoint at current cursor location
local function debug_at_cursor()
    local breapoint = "res://" .. vim.fn.expand('%') .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
    local term = Terminal:new({
        cmd = "godot -d -b " .. breapoint,
    })
    term:toggle()
end

-- starts debug session, breaks on crash
local function debug()
    local term = Terminal:new({
        cmd = "godot -d",
    })
    term:toggle()
end

return {
    debug_at_cursor = debug_at_cursor,
    debug = debug
}
