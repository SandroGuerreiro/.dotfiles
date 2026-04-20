require('settings')
require('autocmds')
require('plugin_list')
require('keymaps')
require('lsp')



vim.cmd[[colorscheme vscode]]

-- Tune bufferline colours to match the vscode theme chrome properly:
-- active tab = editor bg, fill/inactive = TabLineFill (slightly different).
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		local normal  = vim.api.nvim_get_hl(0, { name = "Normal",      link = false })
		local tabfill = vim.api.nvim_get_hl(0, { name = "TabLineFill", link = false })
		local chrome  = tabfill.bg or normal.bg
		-- Fill and inactive tab area use the theme's tab chrome colour
		vim.api.nvim_set_hl(0, "BufferLineFill",            { bg = chrome })
		vim.api.nvim_set_hl(0, "BufferLineTabClose",        { bg = chrome })
		-- Hide the offset separator line (tree border is enough)
		vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator", { bg = chrome, fg = chrome })
	end,
})
vim.cmd("doautocmd ColorScheme")
