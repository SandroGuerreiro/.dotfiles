return {
	'nvim-telescope/telescope.nvim',
	branch = '0.1.x',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-treesitter/nvim-treesitter',
		'nvim-telescope/telescope-fzy-native.nvim',
		'nvim-telescope/telescope-live-grep-args.nvim',
		'BurntSushi/ripgrep',
	},
	config = function()
		local telescope = require('telescope')
		local lga_actions = require('telescope-live-grep-args.actions')
		telescope.setup({
			defaults = {
				preview = { treesitter = false },
				sorting_strategy = 'ascending',
				layout_config = {
					prompt_position = 'top',
				},
			},
			extensions = {
				live_grep_args = {
					auto_quoting = false,
					mappings = {
						i = {
							['<C-q>'] = lga_actions.quote_prompt(),
						},
					},
				},
			},
		})
		telescope.load_extension('live_grep_args')
	end,
}
