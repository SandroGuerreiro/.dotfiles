return {
  "folke/persistence.nvim",
  event = "VimEnter",
  lazy = false,
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",
    need = 1,
  },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)
    -- Auto-restore only when nvim is opened with no file arguments
    if vim.fn.argc() == 0 then
      vim.defer_fn(function()
        persistence.load()
        vim.defer_fn(function() vim.cmd("Neotree show") end, 150)
      end, 100)
    end
  end,
  keys = {
    { "<leader>qs", function() require("persistence").load() end,                desc = "Restore session (cwd)" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't save session on exit" },
  },
}
