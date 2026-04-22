return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			source_selector = {
				winbar = false,
				statusline = false,
			},
			default_component_configs = {
				indent = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "\u{2502}",
					last_indent_marker = "\u{2514}",
					highlight = "NeoTreeIndentMarker",
					with_expanders = true,
					expander_collapsed = "\u{eab6}",
					expander_expanded = "\u{eab4}",
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = "\u{e5ff}",
					folder_open = "\u{e5fe}",
					folder_empty = "\u{f114}",
					default = "\u{f15b}",
				},
				modified = {
					symbol = "\u{25cf}",
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
				},
				git_status = {
					symbols = {
						added = "\u{f067}",
						modified = "\u{f040}",
						deleted = "\u{f00d}",
						renamed = "\u{f0045}",
						untracked = "\u{f128}",
						ignored = "\u{f068}",
						unstaged = "\u{f0131}",
						staged = "\u{f00c}",
						conflict = "\u{f071}",
					},
				},
			},
			window = {
				position = "left",
				width = 32,
				mapping_options = {
					noremap = true,
					nowait = true,
				},
				mappings = {
					["<space>"] = "none",
				},
			},
			filesystem = {
				follow_current_file = { enabled = true, leave_dirs_open = false },
				use_libuv_file_watcher = true,
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_name = { ".git" },
					never_show = { ".DS_Store" },
				},
			},
			event_handlers = {
				{
					event = "neo_tree_buffer_enter",
					handler = function()
						vim.cmd([[setlocal relativenumber]])
						vim.opt_local.winbar = "%#NeoTreeNormal# "
					end,
				},
			},
		})
	end,
}
