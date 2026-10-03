local state = require 'custom.plugins.review-comments.state'

return function()
  state.choose_here(function(comment)
    if not comment then return end
    state.sync_lines()
    state.editor(comment.text, state.locate(comment), comment.end_line, comment.start_col, comment.end_col, function(text)
      text = vim.trim(text)
      if text == '' then
        state.remove_comment(comment)
      else
        state.update_comment(comment, text)
      end
    end)
  end)
end
