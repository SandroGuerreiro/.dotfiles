-- ------------------------------------------------------------ 
--			KEYBINDINGS 
-- ------------------------------------------------------------
local keymap = vim.keymap.set

-- Disable arrows movement
keymap('', '<Up>', '<Nop>', {})
keymap('', '<Down>', '<Nop>', {})
keymap('', '<Left>', '<Nop>', {})
keymap('', '<Right>', '<Nop>', {})

-- Center screen after search occurrence
keymap('', 'n', 'nzz', {})
keymap('', 'N', 'Nzz', {})

-- Options to not yank
keymap('x', '<leader>p', '"_dP', {}) -- Replace without yanking
keymap('n', '<leader>d', '"_d', {}) -- Delete without yanking
keymap('n', '<leader>D', '"_D', {}) -- Delete until EOL without yanking
keymap('n', '<leader>c', '"_c', {}) -- Change without yanking
keymap('n', '<leader>C', '"_C', {}) -- Change until EOL without yanking


-- Split keybinds (C-h/j/k/l handled by vim-tmux-navigator plugin)

keymap('n', '<M-|>', '<cmd>vsplit<cr>')
keymap('n', '<M-->', '<cmd>split<cr>')

keymap('n', '<M-q>', '<cmd>q<cr>')

-- Telescope keybinds
local builtin = require('telescope.builtin')
keymap('n', '<leader>ff', builtin.find_files, {})
keymap('n', '<leader>fg', function()
	require('telescope').extensions.live_grep_args.live_grep_args()
end, {})
keymap('n', '<leader>fb', builtin.buffers, {})
keymap('n', '<leader>fs', builtin.current_buffer_fuzzy_find, {})
keymap('n', '<leader>fh', builtin.help_tags, {})

-- Barbar keybinds
local opts = { noremap = true, silent = true }

-- Move to previous/next
keymap('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
keymap('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)

-- Re-order to previous/next
keymap('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
keymap('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)

-- Goto buffer in position...
keymap('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
keymap('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
keymap('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
keymap('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
keymap('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
keymap('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', opts)
keymap('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', opts)
keymap('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', opts)
keymap('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', opts)
keymap('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)

-- Pin/unpin buffer
keymap('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)

-- Close buffer
keymap('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)

-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
keymap('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)

-- Sort automatically by...
keymap('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
keymap('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
keymap('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
keymap('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)

-- Terminal keybinds
keymap('t', '<C-n>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Claude Code: open in horizontal split terminal (below)
keymap('n', '<leader>cc', function()
  vim.cmd('wincmd l')           -- move to the rightmost code buffer
  vim.cmd('split | terminal claude')
end, { desc = 'Open Claude Code in horizontal split' })

-- Open file under cursor in the buffer above (not in the terminal split)
keymap('n', 'gf', function()
  local file = vim.fn.expand('<cfile>')
  local target = nil
  if vim.fn.filereadable(file) == 1 then
    target = file
  else
    local cwd_file = vim.fn.getcwd() .. '/' .. file
    if vim.fn.filereadable(cwd_file) == 1 then
      target = cwd_file
    end
  end
  if target then
    vim.cmd('wincmd k')
    vim.cmd('edit ' .. target)
  else
    vim.notify('File not found: ' .. file, vim.log.levels.WARN)
  end
end, { desc = 'Go to file (opens in buffer above)' })

-- Pick from files Claude has touched (fzf picker)
keymap('n', '<leader>cf', function()
  -- Scope log per tmux window so each session is isolated
  local session_id = vim.fn.system("tmux display-message -p '#{session_name}:#{window_index}' 2>/dev/null"):gsub('%s+$', '')
  if session_id == '' then
    session_id = 'default'
  end
  local log = '/tmp/claude-files-' .. session_id .. '.log'
  if vim.fn.filereadable(log) == 0 then
    vim.notify('No files logged yet — start a Claude session first', vim.log.levels.WARN)
    return
  end
  vim.cmd('wincmd k')
  require('telescope.pickers').new({}, {
    prompt_title = 'Claude Touched Files',
    finder = require('telescope.finders').new_oneshot_job({ 'cat', log }),
    sorter = require('telescope.config').values.generic_sorter({}),
  }):find()
end, { desc = 'Pick from files Claude touched' })
