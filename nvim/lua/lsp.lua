-- Enhanced capabilities from nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- LSP keymaps (set on attach)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<C-LeftMouse>', vim.lsp.buf.definition, opts)
  end,
})

-- LSP server configs (vim.lsp.config API for Neovim 0.11+)
vim.lsp.config('lua_ls', { capabilities = capabilities })
vim.lsp.config('gopls', { capabilities = capabilities })
vim.lsp.config('rust_analyzer', { capabilities = capabilities })
vim.lsp.config('eslint', { capabilities = capabilities })

local servers = { 'lua_ls', 'gopls', 'rust_analyzer' }
if vim.fn.executable('vscode-eslint-language-server') == 1 then
  table.insert(servers, 'eslint')
end
vim.lsp.enable(servers)
