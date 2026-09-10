local statusline = require 'mini.statusline'
local default_section_mode = statusline.section_mode

local mode_highlights = {
  'MiniStatuslineModeCommand',
  'MiniStatuslineModeInsert',
  'MiniStatuslineModeNormal',
  'MiniStatuslineModeOther',
  'MiniStatuslineModeReplace',
  'MiniStatuslineModeVisual',
}

local function uppercase_mode(args)
  local mode, mode_highlight = default_section_mode(args)
  return mode:upper(), mode_highlight
end

local function bold_mode_highlights()
  for _, highlight in ipairs(mode_highlights) do
    local current = vim.api.nvim_get_hl(0, { name = highlight, link = false })
    vim.api.nvim_set_hl(0, highlight, vim.tbl_extend('force', current, { bold = true }))
  end
end

statusline.section_mode = uppercase_mode

local group = vim.api.nvim_create_augroup('custom-mini-statusline-mode', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Keep mini.statusline mode labels bold',
  group = group,
  callback = bold_mode_highlights,
})
vim.api.nvim_exec_autocmds('ColorScheme', { group = group })
