local statusline = require 'mini.statusline'
local terminal = require 'custom.helpers.terminal'
local default_section_mode = statusline.section_mode
local default_section_filename = statusline.section_filename
local review_state = require 'custom.plugins.review-comments.state'
local review_storage = require 'custom.plugins.review-comments.storage'

local function uppercase_mode(args)
  local mode, mode_highlight = default_section_mode(args)
  return mode:upper(), mode_highlight
end

statusline.section_mode = uppercase_mode

statusline.section_filename = function(args)
  local filename = default_section_filename(args)
  if not review_state.has_comments(0) then return filename end
  local session = vim.fn.fnamemodify(review_storage.path(), ':t'):gsub('%%', '%%%%')
  return filename .. ' | Review: ' .. session
end

if not terminal.is_console then return end

local ansi_colors = {
  black = 0,
  red = 1,
  green = 2,
  blue = 4,
  magenta = 5,
  white = 7,
  bright_black = 8,
}

local function highlight(foreground, background, bold)
  return {
    ctermfg = ansi_colors[foreground],
    ctermbg = ansi_colors[background],
    bold = bold,
  }
end

local function apply_highlights()
  local highlights = {
    MiniStatuslineDevinfo = highlight('white', 'bright_black'),
    MiniStatuslineFileinfo = highlight('white', 'bright_black'),
    MiniStatuslineFilename = highlight('bright_black', 'black'),
    MiniStatuslineInactive = highlight('bright_black', 'black'),
    MiniStatuslineModeCommand = highlight('black', 'red', true),
    MiniStatuslineModeInsert = highlight('black', 'blue', true),
    MiniStatuslineModeNormal = highlight('black', 'white', true),
    MiniStatuslineModeOther = highlight('black', 'bright_black', true),
    MiniStatuslineModeReplace = highlight('black', 'magenta', true),
    MiniStatuslineModeVisual = highlight('black', 'green', true),
  }

  for name, spec in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, spec)
  end
end

local group = vim.api.nvim_create_augroup('custom-mini-statusline', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Apply ANSI mini.statusline colors',
  group = group,
  callback = apply_highlights,
})
apply_highlights()
