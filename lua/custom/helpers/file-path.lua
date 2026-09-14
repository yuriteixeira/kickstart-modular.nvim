local M = {}

local function current_buffer_path()
  local path = vim.api.nvim_buf_get_name(0)

  if path == '' then
    vim.notify('Current buffer has no file path', vim.log.levels.WARN)
    return nil
  end

  return path
end

function M.insert_absolute()
  local path = current_buffer_path()
  if not path then return end

  vim.api.nvim_put({ path }, 'c', true, true)
end

function M.insert_relative()
  local path = current_buffer_path()
  if not path then return end

  local relative_path = './' .. vim.fn.fnamemodify(path, ':.')
  vim.api.nvim_put({ relative_path }, 'c', true, true)
end

return M
