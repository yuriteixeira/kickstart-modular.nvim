local M = {}
local reader = require 'custom.helpers.base16-palette'

function M.load()
  local palette, err = reader.read(vim.fn.expand '~/.base16_theme')
  if not palette then
    vim.cmd.colorscheme 'default'
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  vim.cmd 'highlight clear'
  require('base16-colorscheme').setup(palette)
  vim.g.colors_name = 'base16-system'
end

function M.refresh()
  if vim.g.colors_name ~= 'base16-system' then return end

  local palette = reader.read(vim.fn.expand '~/.base16_theme')
  if palette and not vim.deep_equal(palette, require('base16-colorscheme').colors) then
    vim.cmd.colorscheme 'base16-system'
  end
end

return M
