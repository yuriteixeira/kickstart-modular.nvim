local storage = require 'custom.plugins.review-comments.storage'

local M = {}
local ns = vim.api.nvim_create_namespace 'custom_review_comments'
local comments = storage.load()
local inline_visible = true
local next_id = 0

for _, comment in ipairs(comments) do
  next_id = math.max(next_id, tonumber(comment.id) or 0)
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = 'Review comments' })
end

local function buffer_path(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' or vim.bo[buf].buftype ~= '' then return nil end
  return vim.fn.fnamemodify(name, ':p')
end

local function display_path(path)
  local cwd = storage.root()
  if path:sub(1, #cwd + 1) == cwd .. '/' then return path:sub(#cwd + 2) end
  return path
end

local function git(path, args)
  local command = { 'git', '-C', vim.fn.fnamemodify(path, ':h') }
  vim.list_extend(command, args)
  local result = vim.system(command, { text = true }):wait()
  if result.code ~= 0 then return nil end
  return vim.trim(result.stdout or '')
end

local function commit_for(path, line)
  local root = git(path, { 'rev-parse', '--show-toplevel' })
  if not root or (path ~= root and path:sub(1, #root + 1) ~= root .. '/') then return nil end
  local output
  if line then
    output = git(path, { 'blame', '-L', line .. ',' .. line, '--porcelain', '--', path })
  else
    output = git(path, { 'rev-parse', '--short', 'HEAD' })
  end
  local hash = output and output:match '^([0-9a-f]+)'
  if not hash or hash:match '^0+$' then return nil end
  return hash:sub(1, 7)
end

local function locate(comment)
  local buf = vim.fn.bufnr(comment.path)
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) and comment.mark then
    local position = vim.api.nvim_buf_get_extmark_by_id(buf, ns, comment.mark, {})
    if #position > 0 then return position[1] + 1 end
  end
  return comment.line
end

local function sync_lines()
  for _, comment in ipairs(comments) do
    if comment.line then
      local current = locate(comment)
      if current then
        comment.line = current
        local buf = vim.fn.bufnr(comment.path)
        if comment.end_mark and buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
          local position = vim.api.nvim_buf_get_extmark_by_id(buf, ns, comment.end_mark, {})
          if #position > 0 then comment.end_line = math.max(current, position[1] + 1) end
        end
      end
    end
  end
end

local function save()
  sync_lines()
  storage.save(comments)
end

local function render(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then return end
  sync_lines()
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local path = buffer_path(buf)
  if not path then return end
  local count = vim.api.nvim_buf_line_count(buf)
  if count == 0 then return end
  for _, comment in ipairs(comments) do
    if comment.path == path and comment.line then
      local line = math.min(math.max(comment.line, 1), count)
      local preview = comment.text:gsub('\n', ' ')
      if #preview > 90 then preview = preview:sub(1, 87) .. '...' end
      local options = {
        sign_text = '◆',
        sign_hl_group = 'DiagnosticSignInfo',
        right_gravity = true,
      }
      if inline_visible then
        options.virt_text = { { '  💬 ' .. preview, 'Comment' } }
        options.virt_text_pos = 'eol'
      end
      comment.mark = vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, options)
      if comment.end_line then
        comment.end_mark = vim.api.nvim_buf_set_extmark(buf, ns, math.min(comment.end_line, count) - 1, 0, {
          right_gravity = true,
        })
      end
    end
  end
end

local function render_all()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then render(buf) end
  end
end

local function review_at_cursor()
  local path = buffer_path(0)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local matches = {}
  for _, comment in ipairs(comments) do
    if comment.path == path and (not comment.line or (line >= (locate(comment) or 0) and line <= (comment.end_line or locate(comment)))) then
      matches[#matches + 1] = comment
    end
  end
  return matches
end

local function choose_here(callback)
  local matches = review_at_cursor()
  if #matches == 0 then return notify('No comments at cursor', vim.log.levels.WARN) end
  if #matches == 1 then return callback(matches[1]) end
  vim.ui.select(matches, { prompt = 'Choose review comment', format_item = function(item) return item.text end }, callback)
end

local function dialog_title(line, end_line)
  local location = 'Comment'
  if line then
    location = end_line and end_line > line and ('Comment on Range ' .. line .. '-' .. end_line) or ('Comment on Line ' .. line)
  end
  return ' ' .. location .. '  (Ctrl-S save, q cancel) '
end

local function editor(initial, line, end_line, on_save)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'markdown'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, initial and vim.split(initial, '\n', { plain = true }) or { '' })
  local width = math.min(80, math.max(30, vim.o.columns - 4))
  local height = math.min(12, math.max(3, vim.o.lines - 4))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor', style = 'minimal', border = 'rounded',
    width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2), col = math.floor((vim.o.columns - width) / 2),
    title = dialog_title(line, end_line),
  })
  vim.keymap.set({ 'n', 'i' }, '<C-s>', function()
    local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n'))
    if text == '' then return notify('Comment cannot be empty', vim.log.levels.WARN) end
    vim.api.nvim_win_close(win, true)
    on_save(text)
  end, { buffer = buf })
  vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

function M.add(scope, start_line, end_line)
  local path = buffer_path(0)
  if not path then return notify('Open a file buffer to add a comment', vim.log.levels.WARN) end
  local line
  if scope ~= 'file' then line = start_line or vim.api.nvim_win_get_cursor(0)[1] end
  local last = line and end_line and end_line > line and end_line or nil
  editor(nil, line, last, function(text)
    next_id = next_id + 1
    comments[#comments + 1] = {
      id = next_id, path = path, line = line, end_line = last,
      commit = commit_for(path, line), text = text,
    }
    save()
    render_all()
  end)
end

function M.edit()
  choose_here(function(comment)
    if not comment then return end
    sync_lines()
    editor(comment.text, locate(comment), comment.end_line, function(text)
      comment.text = text
      save()
      render_all()
    end)
  end)
end

function M.delete()
  choose_here(function(comment)
    if not comment then return end
    for index, item in ipairs(comments) do
      if item == comment then table.remove(comments, index); break end
    end
    save()
    render_all()
  end)
end

function M.show()
  choose_here(function(comment)
    if comment then notify(comment.text .. (comment.commit and ' (commit ' .. comment.commit .. ')' or '')) end
  end)
end

function M.overview()
  local seen = {}
  local paths = {}
  for _, comment in ipairs(comments) do
    if not seen[comment.path] then
      seen[comment.path] = true
      paths[#paths + 1] = comment.path
    end
  end
  if #paths == 0 then return notify('No review comments') end
  table.sort(paths)
  vim.ui.select(paths, { prompt = 'Files with review comments', format_item = display_path }, function(path)
    if path then vim.cmd.edit(vim.fn.fnameescape(path)) end
  end)
end

function M.list()
  if #comments == 0 then return notify('No review comments') end
  vim.ui.select(comments, {
    prompt = 'Review comments',
    format_item = function(item)
      return display_path(item.path) .. (item.line and ':' .. (locate(item) or item.line) or '') .. ' - ' .. item.text:gsub('\n', ' ')
    end,
  }, function(item)
    if not item then return end
    vim.cmd.edit(vim.fn.fnameescape(item.path))
    if item.line then vim.api.nvim_win_set_cursor(0, { math.min(locate(item) or item.line, vim.api.nvim_buf_line_count(0)), 0 }) end
    notify(item.text)
  end)
end

local function navigate(direction)
  local path = buffer_path(0)
  if not path then return notify('Open a file buffer to navigate comments', vim.log.levels.WARN) end

  local lines = {}
  local last_line = vim.api.nvim_buf_line_count(0)
  for _, comment in ipairs(comments) do
    if comment.path == path then
      lines[#lines + 1] = math.min(locate(comment) or 1, last_line)
    end
  end
  if #lines == 0 then return notify('No review comments in this file', vim.log.levels.WARN) end

  table.sort(lines)
  local current = vim.api.nvim_win_get_cursor(0)[1]
  if direction == 1 then
    for _, line in ipairs(lines) do
      if line > current then return vim.api.nvim_win_set_cursor(0, { line, 0 }) end
    end
    return vim.api.nvim_win_set_cursor(0, { lines[1], 0 })
  end
  for index = #lines, 1, -1 do
    if lines[index] < current then return vim.api.nvim_win_set_cursor(0, { lines[index], 0 }) end
  end
  vim.api.nvim_win_set_cursor(0, { lines[#lines], 0 })
end

function M.next() navigate(1) end
function M.previous() navigate(-1) end

function M.toggle()
  inline_visible = not inline_visible
  render_all()
  notify('Inline comments ' .. (inline_visible and 'shown' or 'hidden'))
end

local function anchor(comment)
  local result = display_path(comment.path)
  local first = locate(comment) or comment.line
  if first then
    result = result .. ':~' .. first
    if comment.end_line and comment.end_line > first then result = result .. '-~' .. comment.end_line end
  end
  return result
end

function M.markdown()
  sync_lines()
  local lines = {
    '## Session: `' .. storage.path() .. '`', '',
    'Address my following comments:', '',
  }
  for index, comment in ipairs(comments) do
    local prefix = index .. '. `' .. anchor(comment) .. '`'
    if comment.commit then prefix = prefix .. ' (commit ' .. comment.commit .. ')' end
    local parts = vim.split(comment.text, '\n', { plain = true })
    lines[#lines + 1] = prefix .. ' - ' .. parts[1]
    for part = 2, #parts do lines[#lines + 1] = '   ' .. parts[part] end
  end
  return table.concat(lines, '\n') .. '\n'
end

function M.copy()
  vim.fn.setreg('+', M.markdown())
  notify('Review copied to system clipboard')
end

function M.export(path)
  if not path or path == '' then return notify('Provide an output path', vim.log.levels.WARN) end
  path = vim.fn.fnamemodify(path, ':p')
  if vim.fn.filereadable(path) == 1 then return notify('File already exists: ' .. path, vim.log.levels.ERROR) end
  local ok, err = pcall(vim.fn.writefile, vim.split(M.markdown(), '\n', { plain = true, trimempty = true }), path)
  if not ok then return notify('Export failed: ' .. tostring(err), vim.log.levels.ERROR) end
  notify('Review written to ' .. path)
end

function M.attach(buf)
  if buffer_path(buf) then render(buf) end
end

function M.flush() save() end

return M
