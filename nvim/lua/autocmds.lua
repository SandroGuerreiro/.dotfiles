vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd("NvimTreeOpen")
	end,
})

-- Auto-reload files changed outside of Neovim (e.g. by Claude Code)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	callback = function()
		vim.cmd("checktime")
	end,
})

-- Start in insert mode when entering a terminal buffer
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.cmd("startinsert")
	end,
})
