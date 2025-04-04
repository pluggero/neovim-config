return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- configure treesitter
		treesitter.setup({
			-- enable syntax highlighting
			highlight = {
				enable = true,
				disable = function(_, bufnr)
					local buf_name = vim.api.nvim_buf_get_name(bufnr)
					local file_size = vim.api.nvim_call_function("getfsize", { buf_name })
					local file_type = vim.api.nvim_buf_get_option(bufnr, "filetype")

					-- Disable for large files (size > 256 KB)
					if file_size > 256 * 1024 then
						vim.notify(
							"Treesitter disabled due to large file size (" .. file_size .. " bytes).",
							vim.log.levels.WARN
						)
						return true
					end

					-- Disable for LaTeX files (filetype: 'tex')
					if file_type == "tex" then
						vim.notify("Treesitter disabled for LaTeX file (filetype: 'tex').", vim.log.levels.WARN)
						return true
					end

					return false
				end,
			},

			-- enable indentation
			indent = { enable = true },

			-- enable autotagging (with nvim-ts-autotag plugin)
			autotag = {
				enable = true,
			},

			-- ensure these language parsers are installed
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"c",
				"c_sharp",
			},

			-- incremental selection keymaps
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})

		-- Set keymaps for enabling/disabling Treesitter highlight
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>td", "<cmd>TSDisable highlight<cr>", { desc = "Disable Treesitter highlighting" })
		keymap.set("n", "<leader>te", "<cmd>TSEnable highlight<cr>", { desc = "Enable Treesitter highlighting" })
	end,
}
