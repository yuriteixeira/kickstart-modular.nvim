local state = require 'custom.plugins.review-comments.state'
local storage = require 'custom.plugins.review-comments.storage'

return function()
  local directory = storage.directory()
  vim.fn.setreg('+', directory)
  state.notify('Review session store: ' .. directory .. ' (copied to system clipboard)')
end
