-- LSP Source: https://github.com/seblyng/roslyn.nvim
-- File: lua/config/lsp/roslyn.lua
-- This sets up the roslyn.nvim plugin, along with the common LSP on_attach & capabilities.
-- Handles both C# and Razor/CSHTML (via co-hosting, built into roslyn-language-server) files.
--
-- !To then install the package: :MasonInstall roslyn-language-server
-- This will only work once the lsp is beeing laoded (open a cs and razor file)
-- Or temporarily remove the `ft = {"cs", "razor"}` part of the config to install it
return {
	"seblyng/roslyn.nvim",
	event = { "BufReadPre", "BufNewFile" },
	-- Only load when editing C# and Razor files:
	ft = { "cs", "razor" },

	-- Run BEFORE the plugin is fully loaded
	init = function()
		vim.keymap.set("n", "<leader>ds", function()
			if not vim.g.roslyn_nvim_selected_solution then
				return vim.notify("No solution file found")
			end

			local projects = require("roslyn.sln.api").projects(vim.g.roslyn_nvim_selected_solution)
			local files = vim.iter(projects)
				:map(function(it)
					return vim.fs.dirname(it)
				end)
				:totable()

			local root = vim.fs.dirname(vim.g.roslyn_nvim_selected_solution) or vim.loop.cwd()

			require("telescope.pickers")
				.new({}, {
					cwd = root,
					prompt_title = "Find solution files",
					finder = require("telescope.finders").new_oneshot_job(
						vim.list_extend({ "fd", "--type", "f", "." }, files),
						{ entry_maker = require("telescope.make_entry").gen_from_file({ cwd = root }) }
					),
					sorter = require("telescope.config").values.file_sorter({}),
					previewer = require("telescope.config").values.grep_previewer({}),
				})
				:find()
		end)
	end,

	-- We can pass plugin options using the `opts` key
	-- or a `config` function. We'll show a `config` function
	config = function()
		local roslyn = require("roslyn")

		-- Import existing on_attach and capabilities
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()
		local lsp_utils = require("config.utils.lsp_utils")

		-- Configure roslyn LSP client using vim.lsp.config
		-- `cmd` is left to roslyn.nvim's own auto-discovery: it finds the
		-- `roslyn-language-server` bin shim installed by Mason automatically.
		vim.lsp.config("roslyn", {
			on_attach = lsp_utils.on_attach,
			capabilities = capabilities,
			-- `settings` for Roslyn-specific functionality:
			settings = {
				["csharp|inlay_hints"] = {
					csharp_enable_inlay_hints_for_implicit_object_creation = true,
					csharp_enable_inlay_hints_for_implicit_variable_types = true,
					csharp_enable_inlay_hints_for_lambda_parameter_types = true,
					csharp_enable_inlay_hints_for_types = true,
					dotnet_enable_inlay_hints_for_indexer_parameters = true,
					dotnet_enable_inlay_hints_for_literal_parameters = true,
					dotnet_enable_inlay_hints_for_object_creation_parameters = true,
					dotnet_enable_inlay_hints_for_other_parameters = true,
					dotnet_enable_inlay_hints_for_parameters = true,
					dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
					dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
					dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
				},
				["csharp|code_lens"] = {
					dotnet_enable_references_code_lens = true,
				},
			},
		})

		-- Setup roslyn plugin (plugin-specific config)
		roslyn.setup({
			filewatching = "auto",
			choose_target = nil,
			ignore_target = nil,
			broad_search = true,
			lock_target = false,
		})
	end,
}
