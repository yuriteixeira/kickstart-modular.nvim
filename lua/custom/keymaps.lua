local map = vim.keymap.set

map('n', '<leader>ww', ':w<CR>', { desc = 'File: Save' })
map('n', '<leader><leader>', ':b#<CR>', { desc = 'Buffers: Toggle current buffer with last opened one' })
map('n', '<leader>to', '<cmd>Outline<CR>', { desc = 'Toggle: Outline' })

-- [[ Zoom functionality ]]
local zoom = require 'custom.helpers.zoom'
map('n', '<leader>z', zoom.toggle, { desc = 'Toggle: Zoom current buffer' })
