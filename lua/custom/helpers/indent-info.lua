local M = {}

function M.show()
  vim.cmd 'verbose setlocal filetype? expandtab? shiftwidth? softtabstop? tabstop?'

  if not vim.tbl_isempty(vim.b.editorconfig or {}) then vim.print { editorconfig = vim.b.editorconfig } end
end

return M
