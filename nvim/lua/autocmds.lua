vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" })
		if #clients > 0 then
			local client = clients[1]
			local params = {
				textDocument = vim.lsp.util.make_text_document_params(bufnr),
				range = {
					start = { line = 0, character = 0 },
					["end"] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
				},
				context = { only = { "source.fixAll.eslint" }, diagnostics = {} },
			}
			local result = client:request_sync("textDocument/codeAction", params, 2000, bufnr)
			if result and result.result then
				for _, action in ipairs(result.result) do
					if action.edit then
						vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
					end
				end
			end
		else
			vim.cmd("TSToolsOrganizeImports sync")
		end
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd("Neotree show")
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
