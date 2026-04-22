return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_install = {
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
    })
  end,
}
