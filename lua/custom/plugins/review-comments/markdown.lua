local state = require 'custom.plugins.review-comments.state'
local storage = require 'custom.plugins.review-comments.storage'

local function anchor(comment)
  local result = state.display_path(comment.path)
  local first = state.locate(comment) or comment.line
  if first then
    result = result .. ':~' .. first
    if comment.end_line and comment.end_line > first then result = result .. '-~' .. comment.end_line end
  end
  return result
end

return function()
  state.sync_lines()
  local lines = {
    '## Session: `' .. storage.path() .. '`', '',
    'Address my following comments:', '',
  }
  for index, comment in ipairs(state.comments) do
    local prefix = index .. '. `' .. anchor(comment) .. '`'
    if comment.commit then prefix = prefix .. ' (commit ' .. comment.commit .. ')' end
    local parts = vim.split(comment.text, '\n', { plain = true })
    lines[#lines + 1] = prefix .. ' - ' .. parts[1]
    for part = 2, #parts do lines[#lines + 1] = '   ' .. parts[part] end
  end
  return table.concat(lines, '\n') .. '\n'
end
