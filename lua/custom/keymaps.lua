local map = vim.keymap.set

map('n', '<leader>ww', ':w<CR>', { desc = 'File: Save' })
map('n', '<leader><leader>', ':b#<CR>', { desc = 'Buffers: Toggle current buffer with last opened one' })
map('n', '<leader>to', '<cmd>Outline<CR>', { desc = 'Toggle: Outline' })

-- [[ Diagnostics ]]
local diagnostics = require 'custom.helpers.diagnostics'
map('n', '<leader>td', diagnostics.toggle_inline, { desc = 'Toggle: Inline diagnostics' })

-- [[ Indentation info ]]
local indent_info = require 'custom.helpers.indent-info'
vim.api.nvim_create_user_command('IndentInfo', indent_info.show, { desc = 'Show indentation settings and their origin' })

-- [[ Zoom and focus modes ]]
local zoom = require 'custom.helpers.zoom'
map('n', '<leader>z', zoom.toggle, { desc = 'Toggle: Zoom current buffer' })
map('n', '<leader>zz', function() require('zen-mode').toggle() end, { desc = 'Toggle: Zen mode' })

-- [[ Markdown preview ]]
local markdown = require 'custom.helpers.glow-markdown'
map('n', '<leader>mp', markdown.preview, { desc = 'Toggle: Markdown preview' })
