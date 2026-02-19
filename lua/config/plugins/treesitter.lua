return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local treesitter = require("nvim-treesitter.configs")

		-- configure treesitter
		treesitter.setup({
			-- enable syntax highlighting
			highlight = {
				enable = true,
				disable = function(_, bufnr)
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
					local file_type = vim.api.nvim_buf_get_option(bufnr, "filetype")

					if ok and stats and stats.size > 256 * 1024 then
						return true
					end

					if file_type == "tex" then
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

		-- Warn when treesitter is disabled for a buffer
		vim.api.nvim_create_autocmd("BufReadPost", {
			callback = function(args)
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
				if ok and stats and stats.size > 256 * 1024 then
					vim.notify(
						"Treesitter disabled due to large file size (" .. stats.size .. " bytes).",
						vim.log.levels.WARN
					)
					return
				end
				local file_type = vim.api.nvim_buf_get_option(args.buf, "filetype")
				if file_type == "tex" then
					vim.notify("Treesitter disabled for LaTeX file (filetype: 'tex').", vim.log.levels.WARN)
				end
			end,
		})

		-- Set keymaps for enabling/disabling Treesitter highlight
		vim.keymap.set("n", "<leader>td", "<cmd>TSDisable highlight<cr>", { desc = "Disable Treesitter highlighting" })
		vim.keymap.set("n", "<leader>te", "<cmd>TSEnable highlight<cr>", { desc = "Enable Treesitter highlighting" })
	end,
}
