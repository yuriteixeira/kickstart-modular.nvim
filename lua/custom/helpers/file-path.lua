local M = {}

function M.copy_relative()
  local absolute_path = vim.api.nvim_buf_get_name(0)

  if absolute_path == '' then
    vim.notify('Current buffer has no file path', vim.log.levels.WARN)
    return
  end

  local relative_path = vim.fn.fnamemodify(absolute_path, ':.')
  vim.fn.setreg('+', relative_path)
  vim.notify('Copied file path: ' .. relative_path)
end

return M
