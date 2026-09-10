local map = vim.keymap.set

map(
  'n',
  '<leader>q',
  function()
    vim.diagnostic.setloclist {
      format = require('custom.helpers.diagnostics').format,
    }
  end,
  { desc = 'Open diagnostic [Q]uickfix list' }
)
map('n', '<leader><leader>', ':b#<CR>', { desc = 'Buffers: Toggle current buffer with last opened one' })
map('n', '<leader>ww', ':w<CR>', { desc = 'File: Save' })
map('n', '<leader>to', ':Outline<CR>', { desc = 'Toggle: Outline' })

-- [[ File path ]]
map('n', '<leader>fp', ':FilePath<CR>', { desc = 'File: Copy relative file path to clipboard' })

-- [[ Diagnostics ]]
local diagnostics = require 'custom.helpers.diagnostics'
map('n', '<leader>td', diagnostics.toggle_inline, { desc = 'Toggle: Inline diagnostics' })

-- [[ Zoom ]]
local zoom = require 'custom.helpers.zoom'
map('n', '<leader>z', zoom.toggle, { desc = 'Toggle: Zoom current buffer' })

-- [[ Focus: Zen mode ]]
map('n', '<leader>zz', function() require('zen-mode').toggle() end, { desc = 'Toggle: Zen mode' })

-- [[ Markdown preview ]]
local markdown = require 'custom.helpers.glow-markdown'
map('n', '<leader>tm', markdown.preview, { desc = 'Toggle: Markdown preview' })

-- [[ QQ command: AI answers streamed to the nvim buffer ]]
map('n', '<leader>qq', ':QQ ', { desc = 'AI: Quick Question' })
