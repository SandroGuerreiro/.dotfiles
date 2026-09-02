-- ------------------------------------------------------------
--   GITIGNORE VISIBILITY
--   Single source of truth for whether gitignored files show up
--   in Telescope (find/grep) and Neo-tree.
--   Env files (.env / .env.*) are ALWAYS shown, in both modes.
-- ------------------------------------------------------------
local M = {}

-- true  = respect .gitignore (gitignored files hidden)
-- false = show everything
local hide_gitignored = true

function M.is_hiding()
	return hide_gitignored
end

-- Command for Telescope find_files.
--
-- fd has no "include this even if gitignored" flag, so when we are respecting
-- .gitignore we run a second, unrestricted pass limited to the env files and
-- concatenate: awk drops the duplicates the two passes would otherwise produce.
function M.fd_args()
	local base = "fd --type f --hidden --exclude .git --exclude node_modules"
	if not hide_gitignored then
		return { 'sh', '-c', base .. " --no-ignore" }
	end
	local cmd = base .. "; " .. base .. " --no-ignore --glob '.env*'"
	return { 'sh', '-c', '{ ' .. cmd .. "; } | awk '!seen[$0]++'" }
end

-- Extra arguments for `rg`, used by Telescope live_grep_args.
function M.rg_args()
	local args = { '--hidden', '--glob', '!.git', '--glob', '!node_modules' }
	if not hide_gitignored then
		table.insert(args, '--no-ignore')
	end
	return args
end

-- Neo-tree drives this through filtered_items.visible: true reveals every
-- filtered item (including gitignored ones), false re-applies the filters.
-- Env files use always_show_by_pattern, so they survive both states.
-- Delegate to neo-tree's own toggle_hidden rather than setting the field
-- directly: it redraws via fs._navigate_internal, which a plain refresh()
-- does not do, so a direct mutation never reaches the screen.
local function sync_neotree()
	pcall(function()
		local manager = require('neo-tree.sources.manager')
		local state = manager.get_state('filesystem')
		if not state or not state.filtered_items then
			return
		end
		local should_be_visible = not hide_gitignored
		if state.filtered_items.visible ~= should_be_visible then
			require('neo-tree.sources.filesystem.commands').toggle_hidden(state)
		end
	end)
end

function M.toggle()
	hide_gitignored = not hide_gitignored
	sync_neotree()
	vim.notify(
		hide_gitignored and 'Gitignored files: hidden' or 'Gitignored files: shown',
		vim.log.levels.INFO
	)
end

return M
