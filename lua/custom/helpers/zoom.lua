local M = {}

local is_zoomed = false
local zoom_restore = ''

function M.toggle()
  if is_zoomed then
    vim.cmd(zoom_restore)
    is_zoomed = false
  else
    zoom_restore = vim.fn.winrestcmd()
    vim.cmd 'vertical resize'
    vim.cmd 'resize'
    is_zoomed = true
  end
end

return M
