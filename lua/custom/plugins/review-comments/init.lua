local state = require 'custom.plugins.review-comments.state'
local function action(name) return require('custom.plugins.review-comments.commands.' .. name) end
local command = vim.api.nvim_create_user_command
local keymap = vim.keymap.set

command('ReviewCommentAdd', function(opts)
  if opts.args == 'file' then
    action('add') 'file'
  elseif opts.range > 0 then
    action('add')('line', opts.line1, opts.line2)
  else
    action('add') 'line'
  end
end, { nargs = '?', range = true, complete = function() return { 'file' } end, desc = 'Add a line, selected range, or file review comment' })

command('ReviewCommentShow', action('show'), { desc = 'Show a review comment at the cursor' })
command('ReviewCommentEdit', action('edit'), { desc = 'Edit a review comment at the cursor' })
command('ReviewCommentDelete', action('delete'), { desc = 'Delete a review comment at the cursor' })
command('ReviewCommentList', function() action('list')() end, { desc = 'Browse review comments' })
command('ReviewCommentHistory', action('history'), { desc = 'Browse saved review sessions and jump to comments' })
command('ReviewCommentOverview', action('overview'), { desc = 'Browse files with review comments in this session' })
command('ReviewCommentNext', action('next'), { desc = 'Jump to the next review comment in this file' })
command('ReviewCommentPrevious', action('previous'), { desc = 'Jump to the previous review comment in this file' })
command('ReviewCommentToggle', action('toggle'), { desc = 'Toggle inline review comments; keep gutter signs' })
command('ReviewCommentCopy', action('copy'), { desc = 'Copy the review as Markdown' })
command('ReviewCommentExport', function(opts) action('export')(opts.args) end, {
  nargs = 1,
  complete = 'file',
  desc = 'Write the review as Markdown to a new file',
})

keymap('n', '<leader>rc', '<cmd>ReviewCommentAdd<cr>', { desc = 'Review: Comment on line' })
keymap('x', '<leader>rc', ":<C-u>'<,'>ReviewCommentAdd<cr>", { desc = 'Review: Comment on range' })
keymap('n', '<leader>rC', '<cmd>ReviewCommentAdd file<cr>', { desc = 'Review: Comment on file' })
keymap('n', '<leader>re', '<cmd>ReviewCommentEdit<cr>', { desc = 'Review: Edit comment' })
keymap('n', '<leader>rd', '<cmd>ReviewCommentDelete<cr>', { desc = 'Review: Delete comment' })
keymap('n', '<leader>rl', '<cmd>ReviewCommentList<cr>', { desc = 'Review: List comments' })
keymap('n', '<leader>rh', '<cmd>ReviewCommentHistory<cr>', { desc = 'Review: Browse saved sessions' })
keymap('n', '<leader>ro', '<cmd>ReviewCommentOverview<cr>', { desc = 'Review: Files with comments' })
keymap('n', ']r', '<cmd>ReviewCommentNext<cr>', { desc = 'Review: Next comment' })
keymap('n', '[r', '<cmd>ReviewCommentPrevious<cr>', { desc = 'Review: Previous comment' })
keymap('n', '<leader>rt', '<cmd>ReviewCommentToggle<cr>', { desc = 'Review: Toggle inline comments' })
keymap('n', '<leader>ry', '<cmd>ReviewCommentCopy<cr>', { desc = 'Review: Copy as Markdown' })
keymap('n', '<leader>rx', '<cmd>ReviewCommentExport<cr>', { desc = 'Review: Export as Markdown file' })

local reviewCommentsAutoCmdGroup = vim.api.nvim_create_augroup('ReviewComments', { clear = true })

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufEnter' }, {
  group = reviewCommentsAutoCmdGroup,
  callback = function(args) state.attach(args.buf, args.event == 'BufReadPost') end,
})

vim.api.nvim_create_autocmd('BufWritePost', {
  group = reviewCommentsAutoCmdGroup,
  callback = function(args) state.capture_saved_anchors(args.buf) end,
})

vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufLeave', 'VimLeavePre' }, {
  group = reviewCommentsAutoCmdGroup,
  callback = function() state.flush() end,
})

state.attach(vim.api.nvim_get_current_buf())
