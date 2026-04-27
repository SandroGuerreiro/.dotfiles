return {
  "lambdalisue/suda.vim",
  event = "BufRead",
  init = function()
    vim.g.suda_smart_edit = 1
  end,
}
