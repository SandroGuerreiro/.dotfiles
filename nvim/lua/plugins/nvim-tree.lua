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
      sync_root_with_cwd = true,
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
        update_root = true,
      },
      filters = {
        git_ignored = false,
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
