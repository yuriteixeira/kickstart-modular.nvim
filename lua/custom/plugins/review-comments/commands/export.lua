local state = require 'custom.plugins.review-comments.state'
local markdown = require 'custom.plugins.review-comments.markdown'

return function(path)
  if not path or path == '' then return state.notify('Provide an output path', vim.log.levels.WARN) end
  path = vim.fn.fnamemodify(path, ':p')
  if vim.fn.filereadable(path) == 1 then return state.notify('File already exists: ' .. path, vim.log.levels.ERROR) end
  local ok, err = pcall(vim.fn.writefile, vim.split(markdown(), '\n', { plain = true, trimempty = true }), path)
  if not ok then return state.notify('Export failed: ' .. tostring(err), vim.log.levels.ERROR) end
  state.notify('Review written to ' .. path)
end
