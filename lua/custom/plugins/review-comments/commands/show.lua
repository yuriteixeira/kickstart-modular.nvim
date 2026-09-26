local state = require 'custom.plugins.review-comments.state'

return function()
  state.choose_here(function(comment)
    if comment then state.notify(comment.text .. (comment.commit and ' (commit ' .. comment.commit .. ')' or '')) end
  end)
end
