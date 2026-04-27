return {
  "folke/persistence.nvim",
  event = "VimEnter",
  lazy = false,
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",
    need = 1,
  },
  config = function(_, opts)
    -- Register cleanup before persistence.setup so it fires first on VimLeavePre
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        pcall(vim.cmd, "Neotree close")
        pcall(vim.cmd, "only")
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].buftype == ""
            and vim.api.nvim_buf_get_name(buf) == ""
            and not vim.bo[buf].modified
          then
            pcall(vim.api.nvim_buf_delete, buf, {})
          end
        end
      end,
    })
    local persistence = require("persistence")
    persistence.setup(opts)
    -- Auto-restore only when nvim is opened with no file arguments
    if vim.fn.argc() == 0 then
      vim.defer_fn(function()
        pcall(persistence.load)
        vim.defer_fn(function()
          vim.schedule(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match("neo%-tree") or vim.bo[buf].filetype == "neo-tree" then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
          pcall(vim.cmd, "Neotree show")
        end)
        end, 300)
      end, 100)
    else
      vim.defer_fn(function()
        pcall(vim.cmd, "Neotree show")
      end, 100)
    end
  end,
  keys = {
    { "<leader>qs", function() require("persistence").load() end,                desc = "Restore session (cwd)" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't save session on exit" },
  },
}
