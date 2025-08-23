return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- ╭──────────────────────────────────────────────────────────╮
		-- │ Imports                                                 │
		-- ╰──────────────────────────────────────────────────────────╯
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local lsp_utils = require("config.utils.lsp_utils")

		-- ╭──────────────────────────────────────────────────────────╮
		-- │ Capabilities                                            │
		-- ╰──────────────────────────────────────────────────────────╯
		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- ╭──────────────────────────────────────────────────────────╮
		-- │ Diagnostic Signs                                        │
		-- ╰──────────────────────────────────────────────────────────╯
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		-- ╭──────────────────────────────────────────────────────────╮
		-- │ Handler for All Servers (default)                       │
		-- ╰──────────────────────────────────────────────────────────╯
		local default_handler = function(server)
			lspconfig[server].setup({
				capabilities = capabilities,
				on_attach = lsp_utils.on_attach,
			})
		end

		-- ╭──────────────────────────────────────────────────────────╮
		-- │ Mason LSP Setup Handlers                                │
		-- ╰──────────────────────────────────────────────────────────╯
		mason_lspconfig.setup({
			handlers = {
				-- 1. Default handler (for most servers)
				default_handler,

				-- 2. Override for specific servers
				["svelte"] = function()
					lspconfig.svelte.setup({
						capabilities = capabilities,
						on_attach = function(client, bufnr)
							-- Optionally, do more custom stuff, then call the shared on_attach
							lsp_utils.on_attach(client, bufnr)

							vim.api.nvim_create_autocmd("BufWritePost", {
								pattern = { "*.js", "*.ts" },
								callback = function(ctx)
									client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
								end,
							})
						end,
					})
				end,
				["graphql"] = function()
					lspconfig.graphql.setup({
						capabilities = capabilities,
						on_attach = lsp_utils.on_attach,
						filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
					})
				end,
				["emmet_ls"] = function()
					lspconfig.emmet_ls.setup({
						capabilities = capabilities,
						on_attach = lsp_utils.on_attach,
						filetypes = {
							"html",
							"typescriptreact",
							"javascriptreact",
							"css",
							"sass",
							"scss",
							"less",
							"svelte",
						},
					})
				end,
				["lua_ls"] = function()
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						on_attach = lsp_utils.on_attach,
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
								completion = {
									callSnippet = "Replace",
								},
							},
						},
					})
				end,
				["ts_ls"] = function()
					lspconfig.ts_ls.setup({
						capabilities = capabilities,
						on_attach = lsp_utils.on_attach,
						init_options = {
							preferences = {
								importModuleSpecifierPreference = "relative",
								importModuleSpecifierEnding = "minimal",
							},
						},
					})
				end,
				["angularls"] = function()
					local ok, mason_registry = pcall(require, "mason-registry")
					if not ok then
						vim.notify("Mason registry could not be loaded")
						return
					end

					local angularls_path = mason_registry.get_package("angular-language-server"):get_install_path()
					local ngls_cmd = {
						"ngserver",
						"--stdio",
						"--tsProbeLocations",
						table.concat({
							angularls_path,
							vim.uv.cwd(),
						}, ","),
						"--ngProbeLocations",
						table.concat({
							angularls_path .. "/node_modules/@angular/language-server",
							vim.uv.cwd(),
						}, ","),
						"--experimental-ivy",
					}

					lspconfig.angularls.setup({
						cmd = ngls_cmd,
						on_new_config = function(new_config)
							new_config.cmd = ngls_cmd
						end,
						capabilities = capabilities,
						on_attach = lsp_utils.on_attach,
					})
				end,
			},
		})
	end,
}
