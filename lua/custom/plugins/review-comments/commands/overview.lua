local state = require 'custom.plugins.review-comments.state'

return function()
  local seen = {}
  local paths = {}
  for _, comment in ipairs(state.comments) do
    if not seen[comment.path] then
      seen[comment.path] = true
      paths[#paths + 1] = comment.path
    end
  end
  if #paths == 0 then return state.notify('No review comments') end
  table.sort(paths)
  vim.ui.select(paths, { prompt = 'Files with review comments', format_item = state.display_path }, function(path)
    if path then vim.cmd.edit(vim.fn.fnameescape(path)) end
  end)
end
