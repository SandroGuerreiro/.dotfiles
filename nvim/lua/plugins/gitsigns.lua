return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 300,
      virt_text_pos = "eol",
    },
    current_line_blame_formatter = " <author>, <author_time:%Y-%m-%d> · <summary>",
    signs = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "" },
      topdelete    = { text = "" },
      changedelete = { text = "▎" },
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Full blame popup with commit body
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Git blame (full)")
      -- Toggle inline blame
      map("n", "<leader>gB", gs.toggle_current_line_blame, "Git blame toggle")
      -- Hunk navigation
      map("n", "]h", gs.next_hunk, "Next hunk")
      map("n", "[h", gs.prev_hunk, "Prev hunk")
    end,
  },
}
