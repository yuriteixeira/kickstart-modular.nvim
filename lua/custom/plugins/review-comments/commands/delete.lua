local state = require 'custom.plugins.review-comments.state'

return function()
  state.choose_here(function(comment)
    if comment then state.remove_comment(comment) end
  end)
end
