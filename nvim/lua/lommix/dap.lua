local ok, dap = pcall(require, "dap")

if not ok then
	return
end

local dapvirt  = require("nvim-dap-virtual-text")
local dapui = require("dapui")

dapui.setup()
dapvirt.setup()

vim.keymap.set("n", "<F3>", dapui.toggle, {})
vim.keymap.set("n", "<F4>", ":DapToggleBreakpoint<CR>", {})
vim.keymap.set("n", "<F5>", ":DapContinue<CR>", {})
vim.keymap.set("n", "<F6>", ":DapStepOver<CR>", {})
vim.keymap.set("n", "<F7>", ":DapStepInto<CR>", {})
vim.keymap.set("n", "<F8>", ":DapStepOut<CR>", {})
vim.keymap.set("n", "<F9>", ":DapTerminate<CR>", {})

-- config
vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "⭐️", texthl = "", linehl = "", numhl = "" })

------------------------------------------------------
-- GO
require("dap-go").setup()

------------------------------------------------------
-- GODOT
dap.adapters.godot = {
  type = "server",
  host = '127.0.0.1',
  port = 6006,
}

dap.configurations.gdscript = {
  {
    type = "godot",
    request = "launch",
    name = "Launch scene",
    project = "${workspaceFolder}",
    launch_scene = true,
  }
}
------------------------------------------------------
-- RUST / C / C++
dap.adapters.lldb = {
  type = 'executable',
  command = '/home/linuxbrew/.linuxbrew/bin/lldb-vscode',
  name = 'lldb'
}

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
	program = function()
		local path = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		return path
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

  },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- TODO: finish when bored
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
------------------------------------------------------
-- PHP
------------------------------------------------------
-- JS
