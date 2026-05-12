return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      typescript = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      javascript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
    },
    format_on_save = {
      timeout_ms = 5000,
      lsp_fallback = false,
    },
    formatters = {
      prettierd = {
        condition = function(_, ctx)
          return vim.fs.find(
            { ".prettierrc", ".prettierrc.js", ".prettierrc.json", ".prettierrc.yaml", "prettier.config.js", "prettier.config.ts" },
            { path = ctx.filename, upward = true }
          )[1] ~= nil
        end,
      },
      prettier = {
        condition = function(_, ctx)
          return vim.fs.find(
            { ".prettierrc", ".prettierrc.js", ".prettierrc.json", ".prettierrc.yaml", "prettier.config.js", "prettier.config.ts" },
            { path = ctx.filename, upward = true }
          )[1] ~= nil
        end,
      },
    },
  },
}
