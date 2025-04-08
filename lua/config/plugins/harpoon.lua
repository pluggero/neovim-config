return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		local list = harpoon:list()
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
		keymap.set("n", "<leader>hx", function()
			list:add()
		end, { desc = "Add file to Harpoon" }) -- Add file to Harpoon
		keymap.set("n", "<leader>hm", function()
			harpoon.ui:toggle_quick_menu(list)
		end, { desc = "Toggle Harpoon menu" }) -- Toggle Harpoon menu
		keymap.set("n", "1", function()
			list:select(1)
		end, { desc = "Go to Harpoon file 1" })
		keymap.set("n", "2", function()
			list:select(2)
		end, { desc = "Go to Harpoon file 2" })
		keymap.set("n", "3", function()
			list:select(3)
		end, { desc = "Go to Harpoon file 3" })
		keymap.set("n", "4", function()
			list:select(4)
		end, { desc = "Go to Harpoon file 4" })
	end,
}
