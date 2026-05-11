return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      json = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      markdown = { "prettier" },
    },
    format_on_save = {
      timeout_ms = 2000,
      lsp_fallback = false,
    },
    formatters = {
      prettier = {
        condition = function(_, ctx)
          -- only run if prettier is resolvable from the project
          return vim.fs.find(
            { ".prettierrc", ".prettierrc.js", ".prettierrc.json", ".prettierrc.yaml", "prettier.config.js", "prettier.config.ts" },
            { path = ctx.filename, upward = true }
          )[1] ~= nil
        end,
      },
    },
  },
}
