vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
	callback = function()
		local eslint_attached = #vim.lsp.get_clients({ bufnr = 0, name = "eslint" }) > 0
		if eslint_attached then
			vim.lsp.buf.code_action({
				context = { only = { "source.fixAll.eslint" } },
				apply = true,
			})
		else
			vim.cmd("TSToolsOrganizeImports sync")
		end
	end,
})

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
