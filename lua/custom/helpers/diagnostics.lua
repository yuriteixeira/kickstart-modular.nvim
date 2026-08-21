local M = {}

function M.toggle_inline()
  local enabled = not vim.diagnostic.config().virtual_text
  vim.diagnostic.config { virtual_text = enabled }
  vim.notify('Inline diagnostics ' .. (enabled and 'enabled' or 'disabled'))
end

return M
