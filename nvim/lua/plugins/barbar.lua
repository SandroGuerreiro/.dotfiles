return {
	'romgrk/barbar.nvim',
	dependencies = {
		'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
		'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
	},
	init = function() vim.g.barbar_auto_setup = false end,
	config = function(_, opts)
		-- Upstream bug: win_get_position is called with -1 when a sidebar buffer
		-- is no longer visible in any window. Guard until fixed upstream.
		local orig = vim.api.nvim_win_get_position
		vim.api.nvim_win_get_position = function(win)
			if not vim.api.nvim_win_is_valid(win) then
				return { 0, 0 }
			end
			return orig(win)
		end
		require("barbar").setup(opts)
	end,
	opts = {
		-- Excludes buffers from the tabline
		exclude_ft = {'javascript'},
		exclude_name = {'package.json'},

		 -- Set the filetypes which barbar will offset itself for
		sidebar_filetypes = {
			NvimTree = true,
		},
	},
	version = '^1.0.0', -- optional: only update when a new 1.x version is released
}
