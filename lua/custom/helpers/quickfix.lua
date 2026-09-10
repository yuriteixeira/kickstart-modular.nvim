local M = {}

function M.center_selection_on_open()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('custom-center-quickfix-selection', { clear = true }),
    pattern = 'qf',
    callback = function(event)
      vim.keymap.set('n', '<CR>', '<CR>zz', { buffer = event.buf, desc = 'Open quickfix item centered' })
      vim.keymap.set('n', 'o', 'ozz', { buffer = event.buf, desc = 'Open quickfix item centered' })
    end,
  })
end

return M
