return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  opts = {
    on_attach = function(_, bufnr)
      vim.keymap.set('n', 'gd', '<cmd>TSToolsGoToSourceDefinition<cr>', { buffer = bufnr })
    end,
  },
}
