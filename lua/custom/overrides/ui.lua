-- Highlight's tweaking
local terminal = require 'custom.helpers.terminal'

if terminal.is_graphical then
  -- Transparent Bg
  -- TODO: Convert to Neovim's Lua API calls (like we see below)
  vim.cmd [[ highlight Normal guibg=none ctermbg=none ]]
  vim.cmd [[ highlight NonText guibg=none ctermbg=none ]]
end

local function apply_spell_highlight()
  local style = {
    fg = '#ff5f5f',
    sp = '#ff5f5f',
  }

  if vim.env.TMUX then
    style.underline = true
  else
    style.undercurl = true
  end

  vim.api.nvim_set_hl(0, 'SpellBad', style)
end

local spell_highlight_group = vim.api.nvim_create_augroup('custom-spell-highlight', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  group = spell_highlight_group,
  callback = apply_spell_highlight,
  desc = 'Restore the visible misspelling highlight',
})
apply_spell_highlight()

-- Equalize splits on terminal resize
vim.api.nvim_create_autocmd('VimResized', {
  command = 'wincmd =',
})
