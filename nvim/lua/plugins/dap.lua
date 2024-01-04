return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")

			vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "⭐️", texthl = "", linehl = "", numhl = "" })

			dap.adapters.godot = {
				type = "server",
				host = "127.0.0.1",
				port = 6006,
			}
			dap.configurations.gdscript = {
				{
					type = "godot",
					request = "launch",
					name = "Launch scene",
					project = "${workspaceFolder}",
					launch_scene = true,
				},
			}
			dap.adapters.lldb = {
				type = "executable",
				command = "lldb-vscode-14",
				name = "lldb",
			}
			dap.configurations.cpp = {
				{
					name = "Launch",
					type = "lldb",
					request = "launch",
					program = function()
						local dir = vim.fn.getcwd()
						local base_name = vim.fn.fnamemodify(dir, ':t')
						local path = dir .. "/target/debug/" .. base_name
						return path
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
				},
			}
			dap.configurations.c = dap.configurations.cpp
			dap.configurations.rust = dap.configurations.cpp
			dap.adapters.coreclr = {
				type = "executable",
				command = "netcoredbg",
				args = {},
			}
			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "launch - netcoredbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/.godot/mono/temp/bin/Debug/", "file")
					end,
				},
			}
		end,
		keys = {
			{ "<F4>", ":DapToggleBreakpoint<CR>" },
			{ "<F5>", ":DapContinue<CR>" },
			{ "<F6>", ":DapStepOver<CR>" },
			{ "<F7>", ":DapStepInto<CR>" },
			{ "<F8>", ":DapStepOut<CR>" },
			{ "<F9>", ":DapTerminate<CR>" },
		}
	},
	{
		"leoluz/nvim-dap-go",
		config = function()
			require("dap-go").setup()
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		config = function()
			require("dapui").setup()
		end,
		keys = {
			{ "<F3>", ":lua require('dapui').toggle()<CR>" },
		}
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			require("nvim-dap-virtual-text").setup()
		end
	}
}
