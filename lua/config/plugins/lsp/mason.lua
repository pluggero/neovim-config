return {
	"williamboman/mason.nvim",
	version = "2.3.1",
	dependencies = {
		{ "williamboman/mason-lspconfig.nvim", version = "2.3.0" },
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
			registries = {
				"github:mason-org/mason-registry",
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
				"roslyn-language-server", -- C# / Razor language server (roslyn.nvim)
				"netcoredbg", -- C# debugger
				"ansible-lint",
				"tflint", -- terraform linter
				"jq", -- JSON processor
				"xmlformatter", -- XML formatter
			},
		})
	end,
}
