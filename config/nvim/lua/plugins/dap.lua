return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require("dapui").setup()
			local dap, dapui = require("dap"), require("dapui")

			vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "⭐️", texthl = "", linehl = "", numhl = "" })

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end

			dap.listeners.after.event_terminated["dapui_config"] = function()
				dapui.close()
			end

			dap.listeners.after.event_exited["dapui_config"] = function()
				dapui.close()
			end

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

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = require("mason-registry").get_package("codelldb"):get_install_path()
						.. "/extension/adapter/codelldb",
					args = { "--port", "${port}" },
				},
				name = "lldb",
			}

			dap.adapters.gdb = {
				type = "executable",
				command = "/usr/bin/gdb",
				name = "gdb",
			}

			dap.configurations.rust = {
				{
					name = "Launch",
					type = "codelldb",
					request = "launch",
					program = function()
						local dir = vim.fn.getcwd()
						local base_name = string.lower(vim.fn.fnamemodify(dir, ":t"))
						local path = dir .. "/target/debug/" .. base_name
						print(path)
						return path
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
			}
			-- dap.configurations.zig = {
			--
			-- }

			-- dap.configurations.cpp = {
			-- 	{
			-- 		name = "Launch",
			-- 		type = "lldb",
			-- 		request = "launch",
			-- 		program = function()
			-- 			local dir = vim.fn.getcwd()
			-- 			local base_name = string.lower(vim.fn.fnamemodify(dir, ':t'))
			-- 			local path = dir .. "/target/debug/" .. base_name
			-- 			print(path)
			-- 			return path
			-- 		end,
			-- 		cwd = "${workspaceFolder}",
			-- 		stopOnEntry = false,
			-- 		args = {},
			-- 		runInTerminal = true,
			-- 	},
			-- }
		end,
		keys = {
			{ "<F4>", ":DapToggleBreakpoint<CR>" },
			{ "<F5>", ":DapContinue<CR>" },
			{ "<F6>", ":DapStepOver<CR>" },
			{ "<F7>", ":DapStepInto<CR>" },
			{ "<F8>", ":DapStepOut<CR>" },
			{ "<F9>", ":DapTerminate<CR>" },
			-- { "<F3>", ":lua require('dapui').toggle()<CR>" },
		},
	},
	{
		"leoluz/nvim-dap-go",
		config = function()
			require("dap-go").setup()
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			require("nvim-dap-virtual-text").setup()
		end,
	},
}
