local M = {}

function M.preview()
  local tempfile = vim.fn.tempname() .. ".md"
  vim.cmd("write! " .. tempfile)
  vim.cmd("enew")
  local bufnr = vim.api.nvim_get_current_buf()
  vim.cmd("terminal glow -p " .. tempfile)
  vim.cmd("startinsert!")
  -- Cleanup on close
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = bufnr,
    callback = function()
      vim.loop.fs_unlink(tempfile)
      pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    end,
  })
end

return M
