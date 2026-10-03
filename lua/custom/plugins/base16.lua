local terminal = require 'custom.helpers.terminal'

if terminal.is_console then
  vim.cmd.colorscheme('default')
  return
end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'RRethy/base16-nvim' }

local palette, err = require('custom.helpers.base16-palette').read(vim.fn.expand '~/.base16_theme')
if not palette then
  vim.cmd.colorscheme('default')
  vim.notify(err, vim.log.levels.WARN)
  return
end

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

require('base16-colorscheme').setup(palette)
vim.g.colors_name = 'base16-system'
