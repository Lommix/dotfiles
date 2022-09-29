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

-- config
vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "⭐️", texthl = "", linehl = "", numhl = "" })

require("dap-go").setup()
