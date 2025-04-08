return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		local colors = {
			fg1 = "#282828",
			color2 = "#504945",
			fg2 = "#ddc7a1",
			color3 = "#32302f",
			color4 = "#a89984",
			color5 = "#7daea3",
			color6 = "#a9b665",
			color7 = "#d8a657",
			color8 = "#d3869b",
			color9 = "#ea6962",
		}

		local gruvbox_lualine_theme = {
			normal = {
				a = { fg = colors.fg1, bg = colors.color4, gui = "bold" },
				b = { fg = colors.fg2, bg = colors.color2 },
				c = { fg = colors.fg2, bg = colors.color3 },
			},
			command = { a = { fg = colors.fg1, bg = colors.color5, gui = "bold" } },
			inactive = { a = { fg = colors.fg2, bg = colors.color2 } },
			insert = { a = { fg = colors.fg1, bg = colors.color6, gui = "bold" } },
			replace = { a = { fg = colors.fg1, bg = colors.color7, gui = "bold" } },
			terminal = { a = { fg = colors.fg1, bg = colors.color8, gui = "bold" } },
			visual = { a = { fg = colors.fg1, bg = colors.color9, gui = "bold" } },
		}

		lualine.setup({
			options = {
				theme = gruvbox_lualine_theme,
				component_separators = "|",
				section_separators = "",
			},
			sections = {
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = colors.yellow },
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
