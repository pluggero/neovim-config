return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			-- Registries that should be used.
			registries = {
				"github:mason-org/mason-registry",
				-- Adds a custom registry containing the roslyn and rzls packages.
				-- These packages are currently not included in the mason registry itself.
				-- Source: https://github.com/seblj/roslyn.nvim / https://github.com/tris203/rzls.nvim
				-- TODO: As soon as the packages beeing added to the mason registry we can remove this.
				"github:crashdummyy/mason-registry",
			},

			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"angularls",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"prismals",
				"pyright",
				"dockerls",
				"docker_compose_language_service",
				"ansiblels",
				"bashls",
				"terraformls",
				"lemminx",
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint",
				"eslint_d",
				"debugpy", -- python debugger
				"roslyn",
				"rzls",
				"netcoredbg", -- C# debugger
				"ansible-lint",
				"tflint", -- terraform linter
				"jq", -- JSON processor
				"xmllint", -- XML formatter
			},
		})
	end,
}
