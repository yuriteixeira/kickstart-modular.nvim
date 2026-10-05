-- Run from the config directory with: nvim --headless -u NONE -l lua/custom/tests/base16-palette.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local reader = require 'custom.helpers.base16-palette'
local path = vim.fn.tempname()
local lines = {}
for slot = 0, 21 do
  lines[#lines + 1] = ('color%02d="%02x/ab/cd" # Palette entry'):format(slot, slot)
end
lines[#lines + 1] = 'color01=$color00'
lines[#lines + 1] = "color02='${color01}'"
lines[#lines + 1] = 'touch /tmp/nvim-base16-must-not-execute'
vim.fn.writefile(lines, path)

local palette, err = reader.read(path)
assert(palette, err)
assert(palette.base00 == '#00abcd')
assert(palette.base01 == '#12abcd')
assert(palette.base08 == '#00abcd')
assert(palette.base0B == '#00abcd')
assert(palette.base0F == '#11abcd')
assert(palette.cterm01 == 18)
assert(palette.cterm0F == 17)
assert(vim.tbl_count(palette) == 32)

vim.fn.writefile({ 'color00="invalid"' }, path)
palette, err = reader.read(path)
assert(palette == nil and err:match('Invalid'))
vim.fn.delete(path)
palette, err = reader.read(path)
assert(palette == nil and err:match('Cannot read'))

-- The active system theme has no matching bundled Neovim theme.
vim.env.TERM = 'xterm-256color'
vim.env.BASE16_THEME = 'not-a-bundled-theme'
vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site/pack/core/opt/base16-nvim')
vim.pack.add = function() end
require 'custom.plugins.base16'
palette, err = reader.read(vim.fn.expand '~/.base16_theme')
assert(palette, err)
assert(require('base16-colorscheme').colors.base00 == palette.base00)
local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
assert(normal.bg == tonumber(palette.base00:sub(2), 16))
assert(normal.ctermbg == palette.cterm00)
assert(vim.g.colors_name == 'base16-system')

-- Simulate replacing the system theme symlink without changing the real theme.
local original_read = reader.read
local system_path = vim.fn.expand '~/.base16_theme'
local theme_link = vim.fn.tempname()
local first_theme = vim.fn.tempname()
local second_theme = vim.fn.tempname()
vim.fn.writefile(lines, first_theme)
local changed_lines = vim.deepcopy(lines)
changed_lines[1] = 'color00="ff/ee/dd"'
vim.fn.writefile(changed_lines, second_theme)
assert(vim.uv.fs_symlink(first_theme, theme_link))

reader.read = function(theme_path)
  return original_read(theme_path == system_path and theme_link or theme_path)
end

vim.cmd.colorscheme 'base16-system'
assert(vim.api.nvim_get_hl(0, { name = 'Normal' }).bg == 0x00abcd)
assert(vim.uv.fs_unlink(theme_link))
assert(vim.uv.fs_symlink(second_theme, theme_link))
vim.api.nvim_exec_autocmds('FocusGained', {})
assert(vim.api.nvim_get_hl(0, { name = 'Normal' }).bg == 0xffeedd)
assert(require('base16-colorscheme').colors.base00 == '#ffeedd')

-- Do not reset highlights when the palette has not changed.
vim.api.nvim_set_hl(0, 'Normal', { bg = '#123456' })
vim.api.nvim_exec_autocmds('FocusGained', {})
assert(vim.api.nvim_get_hl(0, { name = 'Normal' }).bg == 0x123456)
vim.cmd.colorscheme 'base16-system'
assert(vim.api.nvim_get_hl(0, { name = 'Normal' }).bg == 0xffeedd)

-- Keep transparency after an explicit reload or a focus change.
require 'custom.overrides.ui'
assert(vim.api.nvim_get_hl(0, { name = 'Normal' }).bg == nil)
vim.cmd.colorscheme 'base16-system'
assert(vim.api.nvim_get_hl(0, { name = 'Normal' }).bg == nil)
assert(vim.uv.fs_unlink(theme_link))
assert(vim.uv.fs_symlink(first_theme, theme_link))
vim.api.nvim_exec_autocmds('FocusGained', {})
assert(require('base16-colorscheme').colors.base00 == '#00abcd')
assert(vim.api.nvim_get_hl(0, { name = 'Normal' }).bg == nil)

-- A focus change must not replace a different colorscheme.
vim.cmd.colorscheme 'default'
vim.api.nvim_exec_autocmds('FocusGained', {})
assert(vim.g.colors_name == 'default')

reader.read = original_read
vim.fn.delete(theme_link)
vim.fn.delete(first_theme)
vim.fn.delete(second_theme)
print('Base16 palette tests passed')
