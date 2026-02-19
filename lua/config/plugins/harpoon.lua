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
		keymap.set("n", "<leader>ha", function()
			list:add()
		end, { desc = "Add file to Harpoon" })
		keymap.set("n", "<leader>hA", function()
			list:prepend()
		end, { desc = "Prepend file to Harpoon" })
		keymap.set("n", "<leader>hm", function()
			harpoon.ui:toggle_quick_menu(list)
		end, { desc = "Toggle Harpoon menu" })
		keymap.set("n", "<leader>hx", function()
			list:remove()
		end, { desc = "Remove file from Harpoon" })
		keymap.set("n", "<leader>1", function()
			list:select(1)
		end, { desc = "Go to Harpoon file 1" })
		keymap.set("n", "<leader>2", function()
			list:select(2)
		end, { desc = "Go to Harpoon file 2" })
		keymap.set("n", "<leader>3", function()
			list:select(3)
		end, { desc = "Go to Harpoon file 3" })
		keymap.set("n", "<leader>4", function()
			list:select(4)
		end, { desc = "Go to Harpoon file 4" })
	end,
}
