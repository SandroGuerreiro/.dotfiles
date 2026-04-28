return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    -- Compat shims: nvim-treesitter main removed these APIs; telescope still calls them
    local ok, parsers = pcall(require, "nvim-treesitter.parsers")
    if ok and not parsers.ft_to_lang then
      parsers.ft_to_lang = function(ft)
        local get_lang = vim.treesitter.language and vim.treesitter.language.get_lang
        return (get_lang and get_lang(ft)) or ft
      end
    end

    if not package.loaded["nvim-treesitter.configs"] then
      package.loaded["nvim-treesitter.configs"] = {
        is_enabled = function(feature, lang, bufnr)
          if feature == "highlight" then
            return vim.treesitter.highlighter.active[bufnr] ~= nil
          end
          return false
        end,
      }
    end

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
