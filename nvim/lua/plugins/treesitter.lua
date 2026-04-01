return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua",
        "typescript",
        "tsx",
        "javascript",
        "rust",
        "go",
        "json",
        "html",
        "css",
        "toml",
        "yaml",
        "bash",
        "markdown",
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
