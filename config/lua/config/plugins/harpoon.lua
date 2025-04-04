return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		local keymap = vim.keymap

		harpoon.setup({
			global_settings = {
				save_on_toggle = true,
				save_on_change = true,
				enter_on_sendcmd = false,
				tmux_autoclose_windows = false,
				excluded_filetypes = { "harpoon" },
			},
		})

		-- Key mappings for Harpoon
		keymap.set(
			"n",
			"<leader>m",
			"<cmd>lua require('harpoon.mark').add_file()<CR>",
			{ desc = "Add file to Harpoon" }
		) -- Add file to Harpoon
		keymap.set(
			"n",
			"<C-e>",
			"<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>",
			{ desc = "Toggle Harpoon menu" }
		) -- Toggle Harpoon menu
		keymap.set("n", "1", "<cmd>lua require('harpoon.ui').nav_file(1)<CR>", { desc = "Go to Harpoon file 1" }) -- Navigate to file 1
		keymap.set("n", "2", "<cmd>lua require('harpoon.ui').nav_file(2)<CR>", { desc = "Go to Harpoon file 2" }) -- Navigate to file 2
		keymap.set("n", "3", "<cmd>lua require('harpoon.ui').nav_file(3)<CR>", { desc = "Go to Harpoon file 3" }) -- Navigate to file 3
		keymap.set("n", "4", "<cmd>lua require('harpoon.ui').nav_file(4)<CR>", { desc = "Go to Harpoon file 4" }) -- Navigate to file 4
	end,
}
