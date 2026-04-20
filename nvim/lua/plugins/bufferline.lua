return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	event = "VeryLazy",
	config = function()
		local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				mode = "buffers",
				themable = true,
				numbers = "none",
				close_command = "bdelete! %d",
				right_mouse_command = "bdelete! %d",
				indicator = {
					style = "underline",
				},
				buffer_close_icon = "\u{f00d}",
				modified_icon = "\u{25cf}",
				close_icon = "\u{f00d}",
				left_trunc_marker = "\u{f0141}",
				right_trunc_marker = "\u{f0142}",
				separator_style = "thin",
				show_buffer_close_icons = true,
				show_close_icon = false,
				show_tab_indicators = true,
				persist_buffer_sort = true,
				enforce_regular_tabs = false,
				always_show_bufferline = true,
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and "\u{ea87}" or "\u{f071}"
					return " " .. icon .. " " .. count
				end,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Explorer",
						text_align = "left",
						separator = true,
					},
				},
				hover = {
					enabled = true,
					delay = 150,
					reveal = { "close" },
				},
			},
		})
	end,
}
