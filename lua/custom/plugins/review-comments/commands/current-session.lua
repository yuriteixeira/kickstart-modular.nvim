local state = require 'custom.plugins.review-comments.state'
local storage = require 'custom.plugins.review-comments.storage'

return function()
  state.notify('Current review session: ' .. vim.fn.fnamemodify(storage.path(), ':t'))
end
