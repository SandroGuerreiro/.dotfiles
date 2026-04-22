return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		local mid_bg = "#2D2D2D"
		local mid_fg = "#D4D4D4"
		local white  = "#ffffff"

		local function section(color)
			return { a = { bg = color,  fg = white,  gui = "bold" },
			         b = { bg = color,  fg = white },
			         c = { bg = mid_bg, fg = mid_fg } }
		end

		local cursor_theme = {
			normal   = section("#0078D4"),
			insert   = section("#27A244"),
			visual   = section("#BF7B1B"),
			replace  = section("#C72E0F"),
			command  = section("#7B2FBE"),
			inactive = { a = { bg = mid_bg, fg = mid_fg },
			             b = { bg = mid_bg, fg = mid_fg },
			             c = { bg = mid_bg, fg = mid_fg } },
		}

		require("lualine").setup({
			options = {
				theme = cursor_theme,
				component_separators = { left = "", right = "" },
				section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
				globalstatus = true,
				disabled_filetypes = {
					statusline = { "neo-tree", "lazy", "mason" },
				},
			},
			sections = {
				lualine_a = { { "mode", icon = "" } },
				lualine_b = {
					{ "branch", icon = "\u{e725}" },
					{ "diff",
						symbols = {
							added = "\u{f067} ",
							modified = "\u{f040} ",
							removed = "\u{f00d} ",
						},
					},
				},
				lualine_c = {
					{ "filename", path = 1, symbols = { modified = "\u{25cf}", readonly = "\u{f023}", unnamed = "\u{f15b}" } },
				},
				lualine_x = {
					{ "diagnostics",
						sources = { "nvim_lsp" },
						symbols = {
							error = "\u{ea87} ",
							warn = "\u{f071} ",
							info = "\u{f129} ",
							hint = "\u{f0eb} ",
						},
					},
					{ "encoding", show_bomb = true },
					{ "filetype", icon_only = false },
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "location" },
			},
		})
	end,
}
