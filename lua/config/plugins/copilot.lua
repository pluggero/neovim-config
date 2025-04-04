return {
	"github/copilot.vim",
	config = function()
		local keymap = vim.keymap

		keymap.set("i", "<C-r>", 'copilot#Accept("<CR>")', {
			expr = true,
			noremap = true,
			silent = true,
			replace_keycodes = false,
			desc = "Accept Copilot suggestion",
		})

		vim.g.copilot_no_tab_map = true
		vim.b.copilot_enabled = false
	end,
}
