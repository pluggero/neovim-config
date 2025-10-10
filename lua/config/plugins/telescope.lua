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
		local vimgrep_args_standard = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		}

		local vimgrep_args_all = vim.list_extend(vim.deepcopy(vimgrep_args_standard), {
			"--no-ignore", -- Include files ignored by .gitignore
			"--hidden", -- Search hidden files
			"--text", -- Force binary files to be treated as text
		})

		telescope.setup({
			defaults = {
				vimgrep_arguments = vimgrep_args_all, -- Default: search all files
				sorting_strategy = "ascending", -- Ensures results are listed top-to-bottom
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
		})

		telescope.load_extension("fzf")

		-- Toggle function for vimgrep arguments
		local function toggle_vimgrep_args()
			local current = require("telescope.config").values.vimgrep_arguments
			local is_all = vim.deep_equal(current, vimgrep_args_all)

			if is_all then
				telescope.setup({
					defaults = {
						vimgrep_arguments = vimgrep_args_standard,
					},
				})
				vim.notify("Telescope: Search Mode Restricted", vim.log.levels.INFO)
			else
				telescope.setup({
					defaults = {
						vimgrep_arguments = vimgrep_args_all,
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
