return {
	"nvim-tree/nvim-tree.lua",
	version = "1.15.0",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local nvimtree = require("nvim-tree")

		-- recommended settings from nvim-tree documentation
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		nvimtree.setup({
			view = {
				width = 40,
				relativenumber = true,
			},
			-- change folder arrow icons
			renderer = {
				indent_markers = {
					enable = true,
				},
				icons = {
					glyphs = {
						folder = {
							arrow_closed = "", -- arrow when folder is closed
							arrow_open = "", -- arrow when folder is open
						},
					},
				},
			},
			-- disable window_picker for
			-- explorer to work well with
			-- window splits
			actions = {
				open_file = {
					window_picker = {
						enable = false,
					},
				},
			},
			filters = {
				custom = { ".DS_Store" },
			},
			git = {
				ignore = false,
			},
		})

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
		keymap.set("n", "<leader>ef", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" }) -- Focus file explorer
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeFindFile<CR>", { desc = "Find current opened file in explorer" }) -- Find file in explorer
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer

		-- Resize keymaps
		local nvim_tree_api = require("nvim-tree.api")
		local function resize_tree(delta)
			local winid = nvim_tree_api.tree.winid()
			if not winid then
				return
			end
			local w = vim.api.nvim_win_get_width(winid)
			local new_w = w + delta
			vim.api.nvim_win_set_width(winid, new_w)
			nvim_tree_api.tree.resize({ absolute = new_w })
		end

		keymap.set("n", "<leader>el", function()
			resize_tree(5)
		end, { desc = "Widen file explorer" })
		keymap.set("n", "<leader>eh", function()
			resize_tree(-5)
		end, { desc = "Narrow file explorer" })

		-- Transient resize mode: press <leader>ew, then tap l/h to resize, any other key to exit
		local function nvim_tree_resize_mode()
			vim.notify("nvim-tree resize: l=wider  h=narrower  <any>=exit", vim.log.levels.INFO)
			while true do
				local ok, ch = pcall(vim.fn.getchar)
				if not ok then
					break
				end
				local key = type(ch) == "number" and vim.fn.nr2char(ch) or ch
				if key == "l" then
					resize_tree(5)
					vim.cmd("redraw")
				elseif key == "h" then
					resize_tree(-5)
					vim.cmd("redraw")
				else
					break
				end
			end
			vim.cmd("echo ''")
		end
		keymap.set("n", "<leader>ew", nvim_tree_resize_mode, { desc = "File explorer window resize mode (l/h)" })
	end,
}
