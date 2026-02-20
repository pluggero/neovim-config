return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local transform_mod = require("telescope.actions.mt").transform_mod

		local trouble = require("trouble")
		local trouble_telescope = require("trouble.sources.telescope")

		-- or create your custom action
		local custom_actions = transform_mod({
			open_trouble_qflist = function(prompt_bufnr)
				trouble.toggle("quickfix")
			end,
		})

		-- Define vimgrep argument sets
		local vimgrep_args_restricted = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden", -- Search hidden files and directories
		}

		local vimgrep_args_all = vim.list_extend(vim.deepcopy(vimgrep_args_restricted), {
			"--no-ignore", -- Include files ignored by .gitignore
			"--text", -- Force binary files to be treated as text
			"--glob",
			"!.git", -- Exclude .git metadata dir for performance
		})

		-- Define find_command sets
		local find_command_restricted = {
			"rg",
			"--files",
			"--color=never",
			"--smart-case",
			"--hidden", -- Search hidden files and directories
		}

		local find_command_all = vim.list_extend(vim.deepcopy(find_command_restricted), {
			"--no-ignore", -- Include files ignored by .gitignore
			"--glob",
			"!.git", -- Exclude .git metadata dir for performance
		})

		telescope.setup({
			defaults = {
				vimgrep_arguments = vimgrep_args_all, -- Default: search all files
				sorting_strategy = "ascending", -- Ensures results are listed top-to-bottom
				selection_strategy = "follow", -- Keep cursor on same entry when results update
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
						["<C-t>"] = trouble_telescope.open,
					},
				},
			},
			pickers = {
				find_files = {
					find_command = find_command_all, -- Default: find all files
					debounce = 100, -- Smoother typing in large codebases
				},
				live_grep = {
					debounce = 100, -- Smoother typing in large codebases
				},
			},
		})

		telescope.load_extension("fzf")

		-- Toggle function for vimgrep arguments and find command
		local function toggle_vimgrep_args()
			local current = require("telescope.config").values.vimgrep_arguments
			local is_all = vim.deep_equal(current, vimgrep_args_all)

			if is_all then
				telescope.setup({
					defaults = {
						vimgrep_arguments = vimgrep_args_restricted,
					},
					pickers = {
						find_files = {
							find_command = find_command_restricted,
							debounce = 100,
						},
						live_grep = {
							debounce = 100,
						},
					},
				})
				vim.notify("Telescope: Search Mode Restricted", vim.log.levels.INFO)
			else
				telescope.setup({
					defaults = {
						vimgrep_arguments = vimgrep_args_all,
					},
					pickers = {
						find_files = {
							find_command = find_command_all,
							debounce = 100,
						},
						live_grep = {
							debounce = 100,
						},
					},
				})
				vim.notify("Telescope: Search Mode Extended", vim.log.levels.INFO)
			end
		end

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		keymap.set("n", "<leader>fT", toggle_vimgrep_args, { desc = "Toggle Telescope search mode" })
	end,
}
