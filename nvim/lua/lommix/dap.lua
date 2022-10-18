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

require("dap-go").setup()


dap.adapters.godot = {
  type = "server",
  host = '127.0.0.1',
  port = 6006,
}

dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb',
  name = 'lldb'
}

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = '${workspaceFolder}/target/debug/fun', --todo fix
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

  },
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
dap.configurations.gdscript = {
  {
    type = "godot",
    request = "launch",
    name = "Launch scene",
    project = "${workspaceFolder}",
    launch_scene = true,
  }
}
