return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    {
      "JMarkin/nvim-tree.lua-float-preview",
      lazy = true,
    }
  },
  config = function()
    require("nvim-tree").setup{
      update_cwd = true,
      actions = {
        open_file = {
          resize_window = true,
        },
      },
      view = {
        side = "left",
      },
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
      filters = {
        custom = { "^\\.git" }
      },      
      diagnostics = {
        enable = true,
      },
      renderer = {
        highlight_modified = "icon",
      }
    }
  end
}
