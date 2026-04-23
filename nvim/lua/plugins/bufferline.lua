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
			highlights = {
				fill = {
					bg = "#464646",
				},
				background = {
					fg = "#A8A8A8",
					bg = "#464646",
					bold = false,
					italic = false,
				},
				buffer_selected = {
					fg = "#ffffff",
					bg = "#2A2A2A",
					bold = false,
					italic = false,
				},
				buffer_visible = {
					fg = "#A8A8A8",
					bg = "#464646",
				},
				duplicate = {
					fg = "#569CD6",
					bg = "#464646",
					italic = false,
				},
				duplicate_selected = {
					fg = "#569CD6",
					bg = "#2A2A2A",
					italic = false,
				},
				duplicate_visible = {
					fg = "#569CD6",
					bg = "#464646",
					italic = false,
				},
				close_button = {
					fg = "#A8A8A8",
					bg = "#464646",
				},
				close_button_selected = {
					fg = "#A8A8A8",
					bg = "#2A2A2A",
				},
				close_button_visible = {
					fg = "#A8A8A8",
					bg = "#464646",
				},
				separator = {
					fg = { attribute = "bg", highlight = "VertSplit" },
					bg = "#464646",
				},
				separator_selected = {
					fg = { attribute = "bg", highlight = "VertSplit" },
					bg = "#2A2A2A",
				},
				separator_visible = {
					fg = { attribute = "bg", highlight = "VertSplit" },
					bg = "#464646",
				},
				indicator_selected = {
					bg = "#2A2A2A",
				},
				modified = {
					fg = "#A8A8A8",
					bg = "#464646",
				},
				modified_selected = {
					fg = { attribute = "fg", highlight = "Normal" },
					bg = "#2A2A2A",
				},
				modified_visible = {
					fg = "#A8A8A8",
					bg = "#464646",
				},
				diagnostic = {
					bg = "#464646",
				},
				diagnostic_selected = {
					bg = "#2A2A2A",
				},
				error = {
					bg = "#464646",
				},
				error_selected = {
					bg = "#2A2A2A",
				},
				error_diagnostic = {
					bg = "#464646",
				},
				error_diagnostic_selected = {
					bg = "#2A2A2A",
				},
				warning = {
					bg = "#464646",
				},
				warning_selected = {
					bg = "#2A2A2A",
				},
				warning_diagnostic = {
					bg = "#464646",
				},
				warning_diagnostic_selected = {
					bg = "#2A2A2A",
				},
				info = {
					bg = "#464646",
				},
				info_selected = {
					bg = "#2A2A2A",
				},
				info_diagnostic = {
					bg = "#464646",
				},
				info_diagnostic_selected = {
					bg = "#2A2A2A",
				},
			},
			options = {
				mode = "buffers",
				themable = true,
				numbers = "none",
				close_command = function(bufnr)
					if vim.api.nvim_get_current_buf() == bufnr then
						vim.cmd("BufferLineCycleNext")
						if vim.api.nvim_get_current_buf() == bufnr then
							vim.cmd("BufferLineCyclePrev")
						end
					end
					vim.api.nvim_buf_delete(bufnr, { force = true })
				end,
				right_mouse_command = function(bufnr)
					if vim.api.nvim_get_current_buf() == bufnr then
						vim.cmd("BufferLineCycleNext")
						if vim.api.nvim_get_current_buf() == bufnr then
							vim.cmd("BufferLineCyclePrev")
						end
					end
					vim.api.nvim_buf_delete(bufnr, { force = true })
				end,
				name_formatter = function(buf)
					return " " .. buf.name .. " "
				end,
				indicator = {
					style = "none",
				},
				buffer_close_icon = "\u{f00d}",
				modified_icon = "\u{25cf}",
				close_icon = "\u{f00d}",
				left_trunc_marker = "\u{f0141}",
				right_trunc_marker = "\u{f0142}",
				separator_style = "thin",
				tab_size = 1,
				max_name_length = 28,
				show_buffer_icons = true,
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
						text = "\u{e5ff}  Explorer",
						text_align = "left",
						highlight = "NeoTreeNormal",
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
