local state = require 'custom.plugins.review-comments.state'

return function(comments, prompt)
  comments = type(comments) == 'table' and comments or state.comments
  if #comments == 0 then return state.notify('No review comments') end
  vim.ui.select(comments, {
    prompt = prompt or 'Review comments',
    format_item = function(item)
      return state.display_path(item.path) .. (item.line and ':' .. (state.locate(item) or item.line) or '') .. ' - ' .. item.text:gsub('\n', ' ')
    end,
  }, function(item)
    if not item then return end
    vim.cmd.edit(vim.fn.fnameescape(item.path))
    if item.line then vim.api.nvim_win_set_cursor(0, { math.min(state.locate(item) or item.line, vim.api.nvim_buf_line_count(0)), 0 }) end
    state.notify(item.text)
  end)
end
