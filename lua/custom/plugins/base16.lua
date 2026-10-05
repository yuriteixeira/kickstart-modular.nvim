local terminal = require 'custom.helpers.terminal'

if terminal.is_console then
  vim.cmd.colorscheme('default')
  return
end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'RRethy/base16-nvim' }

require('base16-colorscheme').with_config {
  telescope = true,
  telescope_borders = true,
  indentblankline = true,
  notify = true,
  ts_rainbow = true,
  cmp = true,
  illuminate = true,
  lsp_semantic = true,
  mini_completion = true,
  dapui = true,
  diffview = true,
}

-- Make the personal colors directory available to :colorscheme.
local custom_path = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h')
vim.opt.runtimepath:prepend(custom_path)
vim.cmd.colorscheme 'base16-system'

local group = vim.api.nvim_create_augroup('custom-base16-system', { clear = true })
vim.api.nvim_create_autocmd('FocusGained', {
  group = group,
  nested = true,
  callback = require('custom.helpers.base16-system').refresh,
  desc = 'Reload the system Base16 palette when it changes',
})
