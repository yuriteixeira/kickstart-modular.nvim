local gitsigns = require 'gitsigns'

local function map(bufnr, mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end

local function next_hunk()
  if vim.wo.diff then
    vim.cmd.normal { ']c', bang = true }
  else
    gitsigns.nav_hunk 'next'
  end
end

local function previous_hunk()
  if vim.wo.diff then
    vim.cmd.normal { '[c', bang = true }
  else
    gitsigns.nav_hunk 'prev'
  end
end

local function stage_visual_hunk() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end

local function reset_visual_hunk() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end

local function blame_line() gitsigns.blame_line { full = true } end

local function diff_last_commit() gitsigns.diffthis '@' end

local function all_hunks_to_quickfix() gitsigns.setqflist 'all' end

local function on_attach(bufnr)
  map(bufnr, 'n', ']c', next_hunk, 'Jump to next git [c]hange')
  map(bufnr, 'n', '[c', previous_hunk, 'Jump to previous git [c]hange')

  map(bufnr, 'v', '<leader>hs', stage_visual_hunk, 'git [s]tage hunk')
  map(bufnr, 'v', '<leader>hr', reset_visual_hunk, 'git [r]eset hunk')
  map(bufnr, 'n', '<leader>hs', gitsigns.stage_hunk, 'git [s]tage hunk')
  map(bufnr, 'n', '<leader>hr', gitsigns.reset_hunk, 'git [r]eset hunk')
  map(bufnr, 'n', '<leader>hS', gitsigns.stage_buffer, 'git [S]tage buffer')
  map(bufnr, 'n', '<leader>hR', gitsigns.reset_buffer, 'git [R]eset buffer')
  map(bufnr, 'n', '<leader>hp', gitsigns.preview_hunk, 'git [p]review hunk')
  map(bufnr, 'n', '<leader>hi', gitsigns.preview_hunk_inline, 'git preview hunk [i]nline')
  map(bufnr, 'n', '<leader>hb', blame_line, 'git [b]lame line')
  map(bufnr, 'n', '<leader>hd', gitsigns.diffthis, 'git [d]iff against index')
  map(bufnr, 'n', '<leader>hD', diff_last_commit, 'git [D]iff against last commit')
  map(bufnr, 'n', '<leader>hQ', all_hunks_to_quickfix, 'git hunk [Q]uickfix list (all files in repo)')
  map(bufnr, 'n', '<leader>hq', gitsigns.setqflist, 'git hunk [q]uickfix list (all changes in this file)')

  map(bufnr, 'n', '<leader>tb', gitsigns.toggle_current_line_blame, '[T]oggle git show [b]lame line')
  map(bufnr, 'n', '<leader>tw', gitsigns.toggle_word_diff, '[T]oggle git intra-line [w]ord diff')
  map(bufnr, { 'o', 'x' }, 'ih', gitsigns.select_hunk, 'text object [i]nside [h]unk')
end

gitsigns.setup { on_attach = on_attach }
