-- Provides the server definitions (lsp/*.lua) consumed by vim.lsp.config()
-- and vim.lsp.enable() in lua/lsp.lua. Loaded eagerly so the definitions are
-- on the runtimepath before lua/lsp.lua enables any server.
return {
	"neovim/nvim-lspconfig",
	lazy = false,
	priority = 1000,
}
