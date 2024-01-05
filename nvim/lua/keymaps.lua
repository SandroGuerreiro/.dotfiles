-- ------------------------------------------------------------ 
--			KEYBINDINGS 
-- ------------------------------------------------------------
local keymap = vim.keymap.set

-- Disable arrows movement
keymap('', '<Up>', '<Nop>', {})
keymap('', '<Down>', '<Nop>', {})
keymap('', '<Left>', '<Nop>', {})
keymap('', '<Right>', '<Nop>', {})
keymap('', '<Down>', '<Nop>', {})

-- Center screen after search occurrence
keymap('', 'n', 'nzz', {})
keymap('', 'N', 'Nzz', {})

-- Options to not yank
keymap('x', '<leader>p', '--_dP', {}) -- Replace without yanking
keymap('n', '<leader>d', '--_d', {}) -- Delete without yanking'
keymap('n', '<leader>D', '--_D', {}) -- Delete until EOL without yanking
keymap('n', '<leader>c', '--_c', {}) -- Ckange without yanking
keymap('n', '<leader>C', '--_C', {}) -- Change until EOL without yanking

-- Yank to clipboard
keymap('', '<leader>y', '--+y', {}) -- Yank to os clipboard
keymap('', '<leader>Y', '--+y$', {}) -- Yank until EOL to clipboard
keymap('n', '<leader>p', '--+p', {}) -- Paste after cursor from clipboard
keymap('n', '<leader>P', '--+P', {}) -- Paste before cursor from clipboard

-- Split keybinds
keymap({'n', 't'}, '<C-h>', '<C-w>h')
keymap({'n', 't'}, '<C-j>', '<C-w>j')
keymap({'n', 't'}, '<C-k>', '<C-w>k')
keymap({'n', 't'}, '<C-l>', '<C-w>l')

keymap('n', '<M-|>', '<cmd>vsplit<cr>')
keymap('n', '<M-->', '<cmd>split<cr>')

keymap('n', '<M-q>', '<cmd>q<cr>')

-- Telescope keybinds
local builtin = require('telescope.builtin')
keymap('n', '<leader>ff', builtin.find_files, {})
keymap('n', '<leader>fg', builtin.live_grep, {})
keymap('n', '<leader>fb', builtin.buffers, {})
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
