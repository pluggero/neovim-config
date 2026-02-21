return {
	{
		"mfussenegger/nvim-dap",
		version = "0.10.0",
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
			keymap.set("n", "<Leader>dc", dap.continue, { desc = "Connect Debugging Session" })
			keymap.set("n", "<Leader>dd", dap.disconnect, { desc = "Disconnect Debugging Session" })
			keymap.set("n", "<F5>", dap.continue, { silent = true, noremap = true, desc = "Connect Debugging Session" })
			keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over Function" })
			keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into Function" })
			keymap.set("n", "<F12>", dap.step_out, { desc = "Step Out Function" })

			local dap_utils = require("dap.utils")

			-- Add netcoredbg configuration for C#
			local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"

			local netcoredbg_adapter = {
				type = "executable",
				command = mason_path,
				args = { "--interpreter=vscode" },
			}

			dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
			dap.adapters.coreclr = netcoredbg_adapter -- needed for unit test debugging

			local dotnet = require("config.utils.nvim-dap-dotnet")

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch",
					request = "launch",
					program = function()
						return dotnet.build_dll_path()
					end,
				},
				{
					type = "coreclr",
					name = "Attach",
					request = "attach",
					processId = dap_utils.pick_process,
				},
				{
					type = "coreclr",
					name = "Attach (Smart)",
					request = "attach",
					processId = function()
						local current_working_dir = vim.fn.getcwd()
						return dotnet.smart_pick_process(dap_utils, current_working_dir) or dap.ABORT
					end,
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
