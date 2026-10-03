local state = require 'custom.plugins.review-comments.state'

return function(scope, start_line, end_line, start_col, end_col)
  local path = state.buffer_path(0)
  if not path then return state.notify('Open a file buffer to add a comment', vim.log.levels.WARN) end
  local line
  if scope ~= 'file' then line = start_line or vim.api.nvim_win_get_cursor(0)[1] end
  local last = line and end_line and end_line > line and end_line or nil
  local first_col = line and start_col and start_col > 0 and start_col or nil
  local final_col = first_col and end_col and end_col > 0 and end_col or nil
  state.editor(nil, line, last, first_col, final_col, function(text)
    state.add_comment(path, line, last, text, first_col, final_col)
  end)
end
