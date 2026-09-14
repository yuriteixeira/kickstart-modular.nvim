local M = {}

local function current_buffer_path()
  local path = vim.api.nvim_buf_get_name(0)

  if path == '' then
    vim.notify('Current buffer has no file path', vim.log.levels.WARN)
    return nil
  end

  return path
end

function M.copy_absolute()
  local path = current_buffer_path()
  if not path then return end

  vim.fn.setreg('+', path)
  vim.notify('Copied file path: ' .. path)
end

function M.copy_relative()
  local path = current_buffer_path()
  if not path then return end

  local relative_path = './' .. vim.fn.fnamemodify(path, ':.')
  vim.fn.setreg('+', relative_path)
  vim.notify('Copied file path: ' .. relative_path)
end

return M
