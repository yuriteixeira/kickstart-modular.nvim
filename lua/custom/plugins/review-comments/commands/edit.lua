local state = require 'custom.plugins.review-comments.state'

return function()
  state.choose_here(function(comment)
    if not comment then return end
    state.sync_lines()
    state.editor(comment.text, state.locate(comment), comment.end_line, function(text)
      state.update_comment(comment, text)
    end)
  end)
end
