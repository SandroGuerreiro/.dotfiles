-- ------------------------------------------------------------ 
--			SETTINGS 
-- ------------------------------------------------------------
local opt = vim.opt
vim.g.mapleader = " "

opt.termguicolors = true 	-- Enable terminal colors
opt.number = true 		-- Enables lines numbers
opt.relativenumber = true 	-- Enables relative line numbers
opt.cursorline = true		-- Enables cursor line
opt.ignorecase = true 		-- Ignore case when searching
opt.splitright = true 		-- Split to the right on vertical
opt.splitbelow = true 		-- Split below when horizontal
opt.wrap = true 		-- Wrap lines
opt.updatetime=100 		-- Time to wait without action before writting to disk
opt.formatoptions:append('cro') -- continue comments when going down a line, hit C-u to remove the added comment prefix
opt.sessionoptions:remove('options') -- don't save keymaps and local options
opt.foldlevelstart = 99 	-- no auto folding

-- Indentation
local tabs = 2
vim.opt.tabstop = tabs
vim.opt.shiftwidth = tabs
vim.opt.autoindent = true	-- indent automatically
vim.opt.smartindent = true	-- §

vim.g.loaded_netrwPlugin = 1 -- disable netrw
vim.g.loaded_netrw = 1 -- disable netrw
