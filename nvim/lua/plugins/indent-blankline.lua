return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = "BufReadPost",
	config = function()
		require("ibl").setup({
			indent = {
				char = "\u{2502}",
				tab_char = "\u{2502}",
			},
			scope = {
				enabled = true,
				show_start = false,
				show_end = false,
			},
			exclude = {
				filetypes = { "neo-tree", "lazy", "mason", "help", "terminal", "dashboard" },
			},
		})
	end,
}
