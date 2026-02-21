return {
	"lervag/vimtex",
	version = "v2.16",
	-- we don't want to lazy load VimTeX
	lazy = false,
	config = function()
		-- VimTeX configuration goes here
		vim.g.vimtex_view_method = "zathura"

		-- Specify the output directory for compiler
		vim.g.vimtex_compiler_latexmk = {
			-- Build directory
			build_dir = "build",
			options = {
				-- Output directory
				"-outdir=build",
			},
			-- Custom dependencies to handle glossaries
			custom_dependencies = {
				{
					target = "build/main.gls",
					source = "build/main.acn",
					commands = { "makeglossaries build/main.acn" },
				},
			},
		}

		-- Set maximum line length for LaTeX files
		vim.api.nvim_command("autocmd FileType tex setlocal textwidth=80")
	end,

	keys = {
		{ "<leader>vc", "<cmd>VimtexCompile<cr>", desc = "Compile LateX document" },
		{ "<leader>vv", "<cmd>VimtexView<cr>", desc = "Open LateX document" },
		{ "<leader>vf", "gq", mode = "v", desc = "Format selected text" },
	},
}
