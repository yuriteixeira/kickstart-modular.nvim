--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'options'
require 'custom.options'

require 'keymaps'
require 'custom.keymaps'

require 'lazy-bootstrap'
require 'lazy-plugins'

require 'custom.overrides'
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
