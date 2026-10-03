local state = require 'custom.plugins.review-comments.state'
local storage = require 'custom.plugins.review-comments.storage'

local function anchor(comment)
  local result = state.display_path(comment.path)
  local first = state.locate(comment) or comment.line
  if first then
    result = result .. ':L' .. first
    if comment.start_col then result = result .. ':C' .. comment.start_col end
    if comment.end_line and comment.end_line > first then
      result = result .. '-L' .. comment.end_line
      if comment.end_col then result = result .. ':C' .. comment.end_col end
    elseif comment.end_col and comment.end_col ~= comment.start_col then
      result = result .. '-L' .. first .. ':C' .. comment.end_col
    end
  end
  return result
end

local function format_comment(comment)
  local parts = vim.split(comment.text, '\n', { plain = true })
  return '`' .. anchor(comment) .. '` - ' .. table.concat(parts, '\n   ')
end

return function()
  state.sync_lines()
  local lines = {
    '## Session: `' .. storage.path() .. '`', '',
    'Address my following comments:', '',
  }
  for index, comment in ipairs(state.comments) do
    local formatted = format_comment(comment)
    if comment.commit then formatted = formatted:gsub(' - ', ' (commit ' .. comment.commit .. ') - ', 1) end
    local parts = vim.split(formatted, '\n', { plain = true })
    lines[#lines + 1] = index .. '. ' .. parts[1]
    for part = 2, #parts do lines[#lines + 1] = parts[part] end
  end
  return table.concat(lines, '\n') .. '\n'
end
