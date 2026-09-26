local state = require 'custom.plugins.review-comments.state'

local M = {}

function M.navigate(direction)
  local path = state.buffer_path(0)
  if not path then return state.notify('Open a file buffer to navigate comments', vim.log.levels.WARN) end

  local lines = {}
  local last_line = vim.api.nvim_buf_line_count(0)
  for _, comment in ipairs(state.comments) do
    if comment.path == path then
      lines[#lines + 1] = math.min(state.locate(comment) or 1, last_line)
    end
  end
  if #lines == 0 then return state.notify('No review comments in this file', vim.log.levels.WARN) end

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

return M
