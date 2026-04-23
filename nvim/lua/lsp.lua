
-- Enhanced capabilities from nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Floating spinner near cursor while waiting on LSP responses
local function make_spinner(message)
  local frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
  local idx = 1
  local active = true
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.max(38, #message + 8)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'cursor',
    row = 1, col = 1,
    width = width, height = 1,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    noautocmd = true,
  })
  vim.wo[win].winhl = 'Normal:NormalFloat,FloatBorder:DiagnosticInfo'
  local function tick()
    if not active then return end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { ' ' .. frames[idx] .. '  ' .. message })
    end
    idx = (idx % #frames) + 1
    vim.defer_fn(tick, 80)
  end
  local function stop()
    active = false
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
  end
  tick()
  return stop
end

local function lsp_def_and_refs()
  local bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({ bufnr = bufnr })[1]
  local encoding = client and client.offset_encoding or 'utf-16'
  local params = vim.lsp.util.make_position_params(0, encoding)
  local results = {}
  local pending = 2
  local stop_spinner = make_spinner('Finding definitions & usages…')

  local function location_to_entry(loc, label)
    local uri = loc.uri or loc.targetUri
    local range = loc.range or loc.targetSelectionRange
    local fname = vim.uri_to_fname(uri)
    local lnum = range.start.line + 1
    local col = range.start.character + 1
    local end_col = range['end'].character + 1
    local lines = vim.fn.readfile(fname)
    local text = lines[lnum] or ''
    return {
      label = label, filename = fname, lnum = lnum,
      col = col, end_col = end_col, text = vim.trim(text),
    }
  end

  local function open_picker()
    stop_spinner()
    if #results == 0 then
      vim.notify('No definitions or references found', vim.log.levels.WARN)
      return
    end

    local pickers       = require('telescope.pickers')
    local finders       = require('telescope.finders')
    local conf          = require('telescope.config').values
    local actions       = require('telescope.actions')
    local action_state  = require('telescope.actions.state')
    local entry_display = require('telescope.pickers.entry_display')
    local previewers    = require('telescope.previewers')

    -- Group results by filename, insert a non-selectable header before each group
    table.sort(results, function(a, b)
      if a.filename ~= b.filename then return a.filename < b.filename end
      if a.lnum    ~= b.lnum    then return a.lnum < b.lnum end
      return (a.label == 'DEF' and 1 or 2) < (b.label == 'DEF' and 1 or 2)
    end)

    local grouped = {}
    local last_file
    for _, r in ipairs(results) do
      if r.filename ~= last_file then
        table.insert(grouped, { is_header = true, filename = r.filename })
        last_file = r.filename
      end
      table.insert(grouped, r)
    end

    local row_displayer = entry_display.create({
      separator = '  ',
      items = {
        { width = 2 },                -- indent
        { width = 4 },                -- DEF / REF label
        { width = 5 },                -- line number
        { remaining = true },         -- matched code line
      },
    })

    local function make_display(entry)
      if entry.is_header then
        local full = vim.fn.fnamemodify(entry.filename, ':~:.')
        return '  ' .. full, { { { 0, #full + 2 }, 'Directory' } }
      end
      return row_displayer({
        { '', 'Comment' },
        { entry.label, entry.label == 'DEF' and 'DiagnosticHint' or 'Comment' },
        { tostring(entry.lnum), 'TelescopeResultsNumber' },
        entry.text,
      })
    end

    local previewer = previewers.new_buffer_previewer({
      define_preview = function(self, entry)
        local preview_bufnr = self.state.bufnr
        local lines = vim.fn.readfile(entry.filename)
        vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, lines)
        local ft = vim.filetype.match({ filename = entry.filename }) or ''
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(preview_bufnr) then return end
          if ft ~= '' then vim.bo[preview_bufnr].filetype = ft end
          if entry.is_header then return end
          pcall(vim.api.nvim_win_set_cursor, self.state.winid, { entry.lnum, entry.col - 1 })
          vim.api.nvim_buf_add_highlight(preview_bufnr, 0, 'TelescopePreviewLine', entry.lnum - 1, 0, -1)
          vim.api.nvim_buf_add_highlight(preview_bufnr, 0, 'TelescopePreviewMatch', entry.lnum - 1, entry.col - 1, entry.end_col - 1)
        end)
      end,
    })

    pickers.new({}, {
      prompt_title = 'Definitions & References',
      finder = finders.new_table({
        results = grouped,
        entry_maker = function(entry)
          if entry.is_header then
            return {
              value = entry, display = make_display,
              ordinal = entry.filename,  -- keep grouped while filtering
              is_header = true,
              filename = entry.filename,
            }
          end
          return {
            value = entry, display = make_display,
            ordinal = entry.filename .. ' ' .. entry.label .. ' ' .. entry.lnum,
            filename = entry.filename, lnum = entry.lnum,
            col = entry.col, end_col = entry.end_col,
            label = entry.label, text = entry.text,
          }
        end,
      }),
      sorter    = conf.generic_sorter({}),
      previewer = previewer,
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local sel = action_state.get_selected_entry()
          if not sel or sel.is_header then
            actions.move_selection_next(prompt_bufnr)
            return
          end
          actions.close(prompt_bufnr)
          vim.cmd('edit ' .. sel.filename)
          vim.api.nvim_win_set_cursor(0, { sel.lnum, sel.col - 1 })
        end)
        -- Skip over header rows when navigating with j/k (C-n/C-p in insert)
        local function skip_headers(dir)
          return function()
            local current = action_state.get_selected_entry()
            if dir == 'next' then actions.move_selection_next(prompt_bufnr)
            else actions.move_selection_previous(prompt_bufnr) end
            local sel = action_state.get_selected_entry()
            if sel and sel.is_header and sel ~= current then
              if dir == 'next' then actions.move_selection_next(prompt_bufnr)
              else actions.move_selection_previous(prompt_bufnr) end
            end
          end
        end
        map({ 'i', 'n' }, '<C-n>', skip_headers('next'))
        map({ 'i', 'n' }, '<C-p>', skip_headers('prev'))
        map({ 'i', 'n' }, '<Down>', skip_headers('next'))
        map({ 'i', 'n' }, '<Up>', skip_headers('prev'))
        return true
      end,
      preview_title      = 'Preview',
      initial_mode       = 'normal',     -- open in normal mode for j/k navigation
      selection_strategy = 'reset',
      layout_strategy    = 'horizontal',
      layout_config = {
        width         = 0.9,
        height        = 0.7,
        preview_width = 0.55,
        preview_cutoff = 1,
      },
      on_complete = {
        function(picker)
          -- Skip the first header row so the preview shows the first occurrence
          vim.schedule(function()
            local sel = action_state.get_selected_entry()
            if sel and sel.is_header then
              actions.move_selection_next(picker.prompt_bufnr)
            end
          end)
        end,
      },
    }):find()
  end

  local function finish()
    pending = pending - 1
    if pending == 0 then vim.schedule(open_picker) end
  end

  vim.lsp.buf_request(bufnr, 'textDocument/definition', params, function(_, response)
    if response then
      local locs = vim.islist(response) and response or { response }
      for _, loc in ipairs(locs) do
        table.insert(results, location_to_entry(loc, 'DEF'))
      end
    end
    finish()
  end)

  local ref_params = vim.deepcopy(params)
  ref_params.context = { includeDeclaration = false }
  vim.lsp.buf_request(bufnr, 'textDocument/references', ref_params, function(_, response)
    if response then
      for _, loc in ipairs(response) do
        table.insert(results, location_to_entry(loc, 'REF'))
      end
    end
    finish()
  end)
end

-- LSP keymaps (set on attach)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gu', lsp_def_and_refs, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<C-LeftMouse>', function()
      local pos = vim.fn.getmousepos()
      vim.api.nvim_set_current_win(pos.winid)
      vim.api.nvim_win_set_cursor(pos.winid, { pos.line, pos.column - 1 })
      vim.schedule(lsp_def_and_refs)
    end, opts)
  end,
})

-- LSP server configs (vim.lsp.config API for Neovim 0.11+)
vim.lsp.config('lua_ls', { capabilities = capabilities })
vim.lsp.config('gopls', { capabilities = capabilities })
vim.lsp.config('rust_analyzer', { capabilities = capabilities })
vim.lsp.config('eslint', { capabilities = capabilities })

local servers = { 'lua_ls', 'gopls', 'rust_analyzer' }
if vim.fn.executable('vscode-eslint-language-server') == 1 then
  table.insert(servers, 'eslint')
end
vim.lsp.enable(servers)
