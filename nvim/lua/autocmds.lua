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
		vim.schedule(function() pcall(vim.cmd, "Neotree show") end)
	end,
})

-- Cursor Default Dark+ theme overrides
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		local hl = vim.api.nvim_set_hl

		-- Editor base (compensated +12 on bg channels for 0.9 opacity)
		hl(0, "Normal",       { bg = "#212121", fg = "#D4D4D4" })
		hl(0, "WinSeparator", { fg = "#212121", bg = "#212121" })
		hl(0, "VertSplit",    { fg = "#212121", bg = "#212121" })
		hl(0, "LineNr",       { fg = "#9A9A9A" })
		hl(0, "CursorLineNr", { fg = "#D0D0D0" })
		hl(0, "Visual",       { bg = "#325B84" })

		-- Neo-tree
		hl(0, "WinBar",   { bg = "#212121", fg = "#212121" })
		hl(0, "WinBarNC", { bg = "#212121", fg = "#212121" })
		hl(0, "NeoTreeNormal",         { bg = "#2D2D2D" })
		hl(0, "NeoTreeNormalNC",       { bg = "#2D2D2D" })
		hl(0, "NeoTreeCursorLine",     { fg = "#ffffff", bg = "#325B84" })
		hl(0, "NeoTreeDirectoryIcon",  { fg = "#dcb67a" })
		hl(0, "NeoTreeDirectoryName",  { fg = "#D4D4D4" })
		hl(0, "NeoTreeFileName",       { fg = "#D4D4D4" })
		hl(0, "NeoTreeFileNameOpened", { fg = "#ffffff" })
		hl(0, "NeoTreeRootName",       { fg = "#D4D4D4", bold = true })
		hl(0, "NeoTreeExpander",       { fg = "#D4D4D4", bg = "#2D2D2D" })
		hl(0, "NeoTreeIndentMarker",   { fg = "#555555", bg = "#2D2D2D" })
		-- Git status colors (from Cursor gitDecoration.* workbench colors)
		hl(0, "NeoTreeGitAdded",       { fg = "#73C991" })
		hl(0, "NeoTreeGitUntracked",   { fg = "#73C991" })
		hl(0, "NeoTreeGitModified",    { fg = "#E2C08D" })
		hl(0, "NeoTreeGitUnstaged",    { fg = "#E2C08D" })
		hl(0, "NeoTreeGitStaged",      { fg = "#73C991" })
		hl(0, "NeoTreeGitDeleted",     { fg = "#F44747" })
		hl(0, "NeoTreeGitRenamed",     { fg = "#73C991" })
		hl(0, "NeoTreeGitConflict",    { fg = "#E4676B" })
		hl(0, "NeoTreeGitIgnored",     { fg = "#8C8C8C" })

		-- Treesitter tokens (mapped from Cursor tokenColors)
		hl(0, "@function",             { fg = "#DCDCAA" })
		hl(0, "@function.call",        { fg = "#DCDCAA" })
		hl(0, "@function.method",      { fg = "#DCDCAA" })
		hl(0, "@function.method.call", { fg = "#DCDCAA" })
		hl(0, "@type",                 { fg = "#4EC9B0" })
		hl(0, "@type.builtin",         { fg = "#4EC9B0" })
		hl(0, "@keyword",              { fg = "#569CD6" })
		hl(0, "@keyword.return",       { fg = "#C586C0" })
		hl(0, "@keyword.operator",     { fg = "#C586C0" })
		hl(0, "@keyword.exception",    { fg = "#C586C0" })
		hl(0, "@conditional",          { fg = "#C586C0" })
		hl(0, "@repeat",               { fg = "#C586C0" })
		hl(0, "@variable",             { fg = "#9CDCFE" })
		hl(0, "@variable.parameter",   { fg = "#9CDCFE" })
		hl(0, "@variable.member",      { fg = "#9CDCFE" })
		hl(0, "@constant",             { fg = "#4FC1FF" })
		hl(0, "@constant.builtin",     { fg = "#4FC1FF" })
		hl(0, "@string",               { fg = "#CE9178" })
		hl(0, "@string.escape",        { fg = "#d7ba7d" })
		hl(0, "@number",               { fg = "#b5cea8" })
		hl(0, "@float",                { fg = "#b5cea8" })
		hl(0, "@comment",              { fg = "#6A9955", italic = true })

		-- LSP semantic tokens (mapped from Cursor semanticTokenColors)
		hl(0, "@lsp.type.function",   { fg = "#DCDCAA" })
		hl(0, "@lsp.type.method",     { fg = "#DCDCAA" })
		hl(0, "@lsp.type.type",       { fg = "#4EC9B0" })
		hl(0, "@lsp.type.class",      { fg = "#4EC9B0" })
		hl(0, "@lsp.type.interface",  { fg = "#4EC9B0" })
		hl(0, "@lsp.type.enum",       { fg = "#4EC9B0" })
		hl(0, "@lsp.type.enumMember", { fg = "#4FC1FF" })
		hl(0, "@lsp.type.variable",   { fg = "#9CDCFE" })
		hl(0, "@lsp.type.parameter",  { fg = "#9CDCFE" })
		hl(0, "@lsp.type.property",   { fg = "#9CDCFE" })
		hl(0, "@lsp.type.namespace",  { fg = "#4EC9B0" })
		hl(0, "@lsp.type.string",     { fg = "#CE9178" })
		hl(0, "@lsp.type.number",     { fg = "#b5cea8" })
		hl(0, "@lsp.type.keyword",    { fg = "#C586C0" })
	end,
})
vim.cmd("doautocmd ColorScheme")

-- Blank winbar in editor buffers (space between bufferline and content)
vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function()
		local ft = vim.bo.filetype
		if ft ~= "neo-tree" and vim.bo.buftype == "" then
			vim.opt_local.winbar = " "
		end
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
