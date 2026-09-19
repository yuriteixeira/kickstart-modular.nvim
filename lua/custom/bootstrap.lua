-- Values consumed while Kickstart plugins are being initialized.
local terminal = require 'custom.helpers.terminal'
vim.g.have_nerd_font = terminal.is_graphical
