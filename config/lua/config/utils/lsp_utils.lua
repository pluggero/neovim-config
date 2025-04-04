-- utils/lsp_utils.lua

-- Reusable on_attach function for Neovim LSP
local M = {}

--- Shared on_attach function for LSP clients
-- @param client table The LSP client object
-- @param bufnr number The buffer number for the attached LSP client
-- ╭──────────────────────────────────────────────────────────╮
-- │ on_attach Function                                      │
-- │  - Sets up keybinds, highlights, etc.                   │
-- ╰──────────────────────────────────────────────────────────╯
function M.on_attach(client, bufnr)
	local buf_map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
	end

	-- Keybindings for LSP features
	buf_map("n", "gr", "<cmd>Telescope lsp_references<CR>", "LSP: [G]oto [R]eferences")
	buf_map("n", "gD", vim.lsp.buf.declaration, "LSP: [G]oto [D]eclaration")
	buf_map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "LSP: [G]oto [D]efinition")
	buf_map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "LSP: [G]oto [I]mplementations")
	buf_map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: [C]ode [A]ction")
	buf_map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: [R]e[n]ame")
	buf_map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "LSP: [D]iagnostics buffer")
	buf_map("n", "<leader>d", vim.diagnostic.open_float, "LSP: line [D]iagnostics")
	buf_map("n", "[d", vim.diagnostic.goto_prev, "LSP: [G]oto previous diagnostic")
	buf_map("n", "]d", vim.diagnostic.goto_next, "LSP: [G]oto next diagnostic")
	buf_map("n", "K", vim.lsp.buf.hover, "LSP: [K]eyword hover")
	buf_map("n", "<leader>rs", ":LspRestart<CR>", "LSP: [R]e[S]tart")

	-- Highlight references if the server supports it
	if client.server_capabilities.documentHighlightProvider then
		local highlight_augroup = vim.api.nvim_create_augroup("lsp_highlight", { clear = false })
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = bufnr,
			group = highlight_augroup,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = bufnr,
			group = highlight_augroup,
			callback = vim.lsp.buf.clear_references,
		})
	end

	-- Toggle inlay hints, if supported
	if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
		buf_map("n", "<leader>th", function()
			vim.lsp.inlay_hint(bufnr, nil)
		end, "LSP: [T]oggle Inlay [H]ints")
	end
end

return M
