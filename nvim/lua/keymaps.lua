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

-- Neo-tree keybind
local opts = { noremap = true, silent = true }
keymap('n', '<leader>e', '<Cmd>Neotree toggle<CR>', opts)
keymap('n', '<leader>o', '<Cmd>Neotree focus<CR>', opts)

-- Bufferline keybinds

-- Move to previous/next
keymap('n', '<A-,>', '<Cmd>BufferLineCyclePrev<CR>', opts)
keymap('n', '<A-.>', '<Cmd>BufferLineCycleNext<CR>', opts)

-- Re-order to previous/next
keymap('n', '<A-<>', '<Cmd>BufferLineMovePrev<CR>', opts)
keymap('n', '<A->>', '<Cmd>BufferLineMoveNext<CR>', opts)

-- Goto buffer in position...
keymap('n', '<A-1>', '<Cmd>BufferLineGoToBuffer 1<CR>', opts)
keymap('n', '<A-2>', '<Cmd>BufferLineGoToBuffer 2<CR>', opts)
keymap('n', '<A-3>', '<Cmd>BufferLineGoToBuffer 3<CR>', opts)
keymap('n', '<A-4>', '<Cmd>BufferLineGoToBuffer 4<CR>', opts)
keymap('n', '<A-5>', '<Cmd>BufferLineGoToBuffer 5<CR>', opts)
keymap('n', '<A-6>', '<Cmd>BufferLineGoToBuffer 6<CR>', opts)
keymap('n', '<A-7>', '<Cmd>BufferLineGoToBuffer 7<CR>', opts)
keymap('n', '<A-8>', '<Cmd>BufferLineGoToBuffer 8<CR>', opts)
keymap('n', '<A-9>', '<Cmd>BufferLineGoToBuffer 9<CR>', opts)
keymap('n', '<A-0>', '<Cmd>BufferLineGoToBuffer -1<CR>', opts)

-- Pin/unpin buffer
keymap('n', '<A-p>', '<Cmd>BufferLineTogglePin<CR>', opts)

-- Close buffer without quitting nvim
keymap('n', '<A-c>', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local listed = vim.fn.getbufinfo({ buflisted = 1 })
  if #listed <= 1 then
    vim.cmd("enew")
    vim.schedule(function()
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  else
    vim.cmd("BufferLineCycleNext")
    if vim.api.nvim_get_current_buf() == bufnr then
      vim.cmd("BufferLineCyclePrev")
    end
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end, opts)

-- Magic buffer-picking mode
keymap('n', '<C-p>', '<Cmd>BufferLinePick<CR>', opts)

-- Sort automatically by...
keymap('n', '<Space>bd', '<Cmd>BufferLineSortByDirectory<CR>', opts)
keymap('n', '<Space>bl', '<Cmd>BufferLineSortByExtension<CR>', opts)
keymap('n', '<Space>br', '<Cmd>BufferLineSortByRelativeDirectory<CR>', opts)
keymap('n', '<Space>bt', '<Cmd>BufferLineSortByTabs<CR>', opts)

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

-- Pick from files Claude has touched or that need review attention
keymap('n', '<leader>cf', function()
  local session_id = vim.fn.system("tmux display-message -p '#{session_name}:#{window_index}' 2>/dev/null"):gsub('%s+$', '')
  if session_id == '' then
    session_id = 'default'
  end

  local touched_log = '/tmp/claude-files-' .. session_id .. '.log'
  local review_log  = '/tmp/claude-review-files-' .. session_id .. '.log'

  local seen = {}
  local files = {}

  local function add(path)
    path = path:gsub('%s+$', '')
    if path ~= '' and not seen[path] then
      seen[path] = true
      table.insert(files, path)
    end
  end

  for _, log in ipairs({ touched_log, review_log }) do
    if vim.fn.filereadable(log) == 1 then
      for line in io.lines(log) do add(line) end
    end
  end

  if #files == 0 then
    vim.notify('No files logged yet — start a Claude session first', vim.log.levels.WARN)
    return
  end

  vim.cmd('wincmd k')
  require('telescope.pickers').new({}, {
    prompt_title = 'Claude Files',
    finder = require('telescope.finders').new_table({ results = files }),
    sorter = require('telescope.config').values.generic_sorter({}),
    previewer = require('telescope.config').values.file_previewer({}),
  }):find()
end, { desc = 'Pick from files Claude touched or flagged in review' })
