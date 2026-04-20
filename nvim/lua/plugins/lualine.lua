return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		require("lualine").setup({
			options = {
				theme = "vscode",
				component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
				section_separators = { left = "", right = "" },
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
