require('settings')
require('autocmds')
require('plugin_list')
require('keymaps')
require('lsp')



vim.cmd[[colorscheme vscode]]

-- Sync bufferline fill/background to the editor background so there's no
-- colour mismatch strip above the editor area.
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
		local bg = normal.bg
		vim.api.nvim_set_hl(0, "BufferLineFill",           { bg = bg })
		vim.api.nvim_set_hl(0, "BufferLineBackground",     { bg = bg })
		vim.api.nvim_set_hl(0, "BufferLineTabClose",       { bg = bg })
		vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator",{ bg = bg, fg = bg })
	end,
})
vim.cmd("doautocmd ColorScheme")
