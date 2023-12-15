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
keymap('x', '<leader>p', '"_dP', {}) -- Replace without yanking
keymap('n', '<leader>d', '"_d', {}) -- Delete without yanking'
keymap('n', '<leader>D', '"_D', {}) -- Delete until EOL without yanking
keymap('n', '<leader>c', '"_c', {}) -- Ckange without yanking
keymap('n', '<leader>C', '"_C', {}) -- Change until EOL without yanking

-- Yank to clipboard
keymap('', '<leader>y', '"+y', {}) -- Yank to os clipboard
keymap('', '<leader>Y', '"+y$', {}) -- Yank until EOL to clipboard
keymap('n', '<leader>p', '"+p', {}) -- Paste after cursor from clipboard
keymap('n', '<leader>P', '"+P', {}) -- Paste before cursor from clipboard

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
