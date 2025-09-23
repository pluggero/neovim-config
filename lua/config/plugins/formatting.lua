return {
	"stevearc/conform.nvim",
	event = { "BufEnter" },
	config = function()
		-- Import conform plugin
		local conform = require("conform")

		-- Formatting timeout for blocking methods (async=false)
		local formatting_timeout = 2000
		-- No lsp_fallback (ensures that formatting on big files works)
		local lsp_fallback = false
		-- Ensure that the method does not block (not used for format_on_save)
		-- If the buffer is modified before the formatter completes, the formatting will be discarded
		local async = true

		-- Configure conform plugin
		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "jq" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
				cs = { "csharpier" },
				xml = { "xmllint" },
			},
			-- Enable format on save initially
			format_on_save = {
				lsp_fallback = lsp_fallback,
				async = false,
				timeout_ms = formatting_timeout,
			},
		})

		-- Set keymaps for formatting
		local keymap = vim.keymap -- for conciseness

		-- Keymap to automatically format buffer
		keymap.set("n", "<leader>fa", function()
			conform.format({
				lsp_fallback = lsp_fallback,
				async = async,
				timeout_ms = formatting_timeout,
			})
		end, { desc = "Format buffer or range automatically" })

		-- Keymap to manually format the buffer with filetype selection
		keymap.set("n", "<leader>fm", function()
			local bufnr = vim.api.nvim_get_current_buf()

			-- List of available filetypes for selection
			local filetypes = {
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
				"svelte",
				"css",
				"html",
				"json",
				"yaml",
				"markdown",
				"graphql",
				"liquid",
				"lua",
				"python",
				"xml",
			}

			-- Always ask the user to pick a filetype from the list
			vim.ui.select(filetypes, { prompt = "Select filetype:" }, function(choice)
				if choice then
					-- Set the filetype based on user selection
					vim.bo[bufnr].filetype = choice
					vim.notify("Filetype set to: " .. choice)

					-- Format the buffer based on the selected filetype
					conform.format({
						lsp_fallback = lsp_fallback,
						async = async,
						bufnr = bufnr,
						timeout_ms = formatting_timeout,
					})
				else
					vim.notify("No filetype selected. Aborting formatting.", vim.log.levels.WARN)
				end
			end)
		end, { desc = "Format file with filetype selection" })

		-- Keymap to enable format on save with 'fe'
		keymap.set("n", "<leader>fe", function()
			-- Dynamically update conform setup to enable format on save
			conform.setup({
				format_on_save = {
					lsp_fallback = lsp_fallback,
					async = false,
					timeout_ms = formatting_timeout,
				},
			})

			vim.notify("Format on save enabled")
		end, { desc = "Enable format on save" })

		-- Keymap to disable format on save with 'fd'
		keymap.set("n", "<leader>fd", function()
			-- Dynamically update conform setup to disable format on save
			conform.setup({
				format_on_save = nil,
			})

			vim.notify("Format on save disabled")
		end, { desc = "Disable format on save" })
	end,
}
