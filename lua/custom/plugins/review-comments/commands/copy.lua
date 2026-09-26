local state = require 'custom.plugins.review-comments.state'
local markdown = require 'custom.plugins.review-comments.markdown'

return function()
  vim.fn.setreg('+', markdown())
  state.notify('Review copied to system clipboard')
end
