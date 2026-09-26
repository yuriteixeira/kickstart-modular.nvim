local review = require 'custom.plugins.review-comments.review'
local command = vim.api.nvim_create_user_command

command('ReviewCommentAdd', function(opts)
  if opts.args == 'file' then
    review.add 'file'
  elseif opts.range > 0 then
    review.add('line', opts.line1, opts.line2)
  else
    review.add 'line'
  end
end, { nargs = '?', range = true, complete = function() return { 'file' } end, desc = 'Add a line, selected range, or file review comment' })

command('ReviewCommentShow', review.show, { desc = 'Show a review comment at the cursor' })
command('ReviewCommentEdit', review.edit, { desc = 'Edit a review comment at the cursor' })
command('ReviewCommentDelete', review.delete, { desc = 'Delete a review comment at the cursor' })
command('ReviewCommentList', review.list, { desc = 'Browse review comments' })
command('ReviewCommentToggle', review.toggle, { desc = 'Toggle inline review comments; keep gutter signs' })
command('ReviewCommentCopy', review.copy, { desc = 'Copy the review as Markdown' })
command('ReviewCommentExport', function(opts) review.export(opts.args) end, {
  nargs = 1,
  complete = 'file',
  desc = 'Write the review as Markdown to a new file',
})

vim.keymap.set('n', '<leader>rc', '<cmd>ReviewCommentAdd<cr>', { desc = 'Review: Comment on line' })
vim.keymap.set('x', '<leader>rc', ":<C-u>'<,'>ReviewCommentAdd<cr>", { desc = 'Review: Comment on range' })
vim.keymap.set('n', '<leader>rC', '<cmd>ReviewCommentAdd file<cr>', { desc = 'Review: Comment on file' })
vim.keymap.set('n', '<leader>rl', '<cmd>ReviewCommentList<cr>', { desc = 'Review: List comments' })
vim.keymap.set('n', '<leader>rt', '<cmd>ReviewCommentToggle<cr>', { desc = 'Review: Toggle inline comments' })

local group = vim.api.nvim_create_augroup('CustomReviewComments', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufEnter' }, {
  group = group,
  callback = function(args) review.attach(args.buf) end,
})
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufLeave', 'VimLeavePre' }, {
  group = group,
  callback = function() review.flush() end,
})
review.attach(vim.api.nvim_get_current_buf())
