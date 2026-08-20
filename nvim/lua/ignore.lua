-- ------------------------------------------------------------
--   GITIGNORE VISIBILITY
--   Single source of truth for whether gitignored files show up
--   in Telescope (find/grep) and Neo-tree.
--   Secrets (.env / .env.*) are ALWAYS excluded, in both modes.
-- ------------------------------------------------------------
local M = {}

-- true  = respect .gitignore (gitignored files hidden)
-- false = show everything except the secret patterns below
local hide_gitignored = true

-- Never surfaced by find, grep or the file tree, whatever the toggle says.
M.secret_patterns = { '.env', '.env.*' }

function M.is_hiding()
	return hide_gitignored
end

-- Command for `fd`, used by Telescope find_files.
function M.fd_args()
	local args = { 'fd', '--type', 'f', '--hidden', '--exclude', '.git', '--exclude', 'node_modules' }
	if not hide_gitignored then
		table.insert(args, '--no-ignore')
	end
	for _, pattern in ipairs(M.secret_patterns) do
		vim.list_extend(args, { '--exclude', pattern })
	end
	return args
end

-- Extra arguments for `rg`, used by Telescope live_grep_args.
function M.rg_args()
	local args = { '--hidden', '--glob', '!.git', '--glob', '!node_modules' }
	if not hide_gitignored then
		table.insert(args, '--no-ignore')
	end
	for _, pattern in ipairs(M.secret_patterns) do
		vim.list_extend(args, { '--glob', '!' .. pattern })
	end
	return args
end

-- Neo-tree drives this through filtered_items.visible: true reveals every
-- filtered item (including gitignored ones), false re-applies the filters.
-- Secrets use never_show*, which `visible` cannot override.
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
