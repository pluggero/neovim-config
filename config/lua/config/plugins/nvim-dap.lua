return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"mfussenegger/nvim-dap-python", -- Python-specific dap
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local api = require("nvim-tree.api")

			-- Function to close nvim-tree
			local function close_nvim_tree()
				if api.tree.is_visible() then
					api.tree.close()
				end
			end

			-- Setup dap-ui
			dapui.setup()

			-- Open dap-ui automatically
			dap.listeners.after.event_initialized["dapui_config"] = function()
				close_nvim_tree()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Keymaps for dap functionality
			local keymap = vim.keymap
			keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
			keymap.set("n", "<Leader>dc", dap.continue, { desc = "Continue Debugging" })
			keymap.set("n", "<Leader>dd", dap.disconnect, { desc = "Disconnect Debugging Session" })
			keymap.set("n", "<F5>", dap.continue, { silent = true, noremap = true, desc = "Continue Debugging" })
			keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over Function" })
			keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into Function" })
			keymap.set("n", "<F12>", dap.step_out, { desc = "Step Out Function" })

			-- Add netcoredbg configuration for C#
			dap.adapters.coreclr = {
				type = "executable",
				command = "/usr/bin/netcoredbg",
				args = { "--interpreter=vscode" },
			}
			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd(), "file")
					end,
					env = {
						ASPNETCORE_ENVIRONMENT = "Development", -- Start in development mode
					},
				},
				{
					type = "coreclr",
					name = "Attach",
					request = "attach",
					processId = require("dap.utils").pick_process,
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd(), "file")
					end,
					env = {
						ASPNETCORE_ENVIRONMENT = "Development", -- Start in development mode
					},
				},
			}
		end,
	},
	{
		-- Python debugging support
		"mfussenegger/nvim-dap-python",
		after = "nvim-dap",
		ft = "python",
		config = function()
			local ok, dap_python = pcall(require, "dap-python")
			if not ok then
				return
			end

			local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
			dap_python.setup(debugpy_path)
		end,
	},
}
