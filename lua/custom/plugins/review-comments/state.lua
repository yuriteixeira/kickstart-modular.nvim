local storage = require 'custom.plugins.review-comments.storage'

local M = {}
local ns = vim.api.nvim_create_namespace 'custom_review_comments'
local comments = storage.load()
local inline_visible = true
local stale_comments = {}
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

local function anchor_text(buf, line)
  if not line or line < 1 or line > vim.api.nvim_buf_line_count(buf) then return nil end
  return vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]
end

local function capture_anchor(comment, buf)
  if not comment.line then return end
  local first = anchor_text(buf, locate(comment))
  if not first then return end
  local last = comment.end_line and anchor_text(buf, comment.end_line) or nil
  comment.anchor = { first = first, last = last }
end

local function check_anchors(buf, path)
  local stale = {}
  for _, comment in ipairs(comments) do
    if comment.path == path and comment.anchor and comment.line then
      local first = anchor_text(buf, comment.line)
      local last = comment.end_line and anchor_text(buf, comment.end_line) or nil
      stale_comments[comment] = first ~= comment.anchor.first or (comment.end_line and last ~= comment.anchor.last)
      if stale_comments[comment] then stale[#stale + 1] = tostring(comment.line) end
    end
  end
  if #stale > 0 then
    notify('Review comment text changed in ' .. display_path(path) .. ' at line(s) ' .. table.concat(stale, ', ') .. '. Check their locations.', vim.log.levels.WARN)
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

function M.add_comment(path, line, end_line, text)
  next_id = next_id + 1
  comments[#comments + 1] = {
    id = next_id, path = path, line = line, end_line = end_line,
    commit = commit_for(path, line), text = text,
  }
  local comment = comments[#comments]
  local buf = vim.fn.bufnr(path)
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then capture_anchor(comment, buf) end
  save()
  render_all()
end

function M.remove_comment(comment)
  for index, item in ipairs(comments) do
    if item == comment then table.remove(comments, index); break end
  end
  stale_comments[comment] = nil
  save()
  render_all()
end

function M.update_comment(comment, text)
  comment.text = text
  save()
  render_all()
end

M.comments = comments
M.notify = notify
M.buffer_path = buffer_path
M.display_path = display_path
M.locate = locate
M.sync_lines = sync_lines
M.choose_here = choose_here
M.editor = editor
M.render_all = render_all

function M.toggle_inline()
  inline_visible = not inline_visible
  render_all()
  notify('Inline comments ' .. (inline_visible and 'shown' or 'hidden'))
end

function M.attach(buf, check_on_reload)
  local path = buffer_path(buf)
  if not path then return end
  local has_marks = false
  for _, comment in ipairs(comments) do
    if comment.path == path and comment.mark then
      local position = vim.api.nvim_buf_get_extmark_by_id(buf, ns, comment.mark, {})
      if #position > 0 then has_marks = true; break end
    end
  end
  if check_on_reload or not has_marks then check_anchors(buf, path) end
  render(buf)
end

function M.capture_saved_anchors(buf)
  local path = buffer_path(buf)
  if not path then return end
  sync_lines()
  for _, comment in ipairs(comments) do
    if comment.path == path and comment.anchor and comment.mark and not stale_comments[comment] then
      local position = vim.api.nvim_buf_get_extmark_by_id(buf, ns, comment.mark, {})
      if #position > 0 then capture_anchor(comment, buf) end
    end
  end
  save()
end

function M.flush() save() end

return M
