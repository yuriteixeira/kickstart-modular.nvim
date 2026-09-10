local map = vim.keymap.set
local cmd = vim.api.nvim_create_user_command

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
local file_path = require 'custom.helpers.file-path'
cmd('FilePath', file_path.copy_relative, { desc = 'Copy relative file path to clipboard' })
map('n', '<leader>fp', ':FilePath<CR>', { desc = 'File: Copy relative file path to clipboard' })

-- [[ Diagnostics ]]
local diagnostics = require 'custom.helpers.diagnostics'
map('n', '<leader>td', diagnostics.toggle_inline, { desc = 'Toggle: Inline diagnostics' })

-- [[ Indentation info ]]
local indent_info = require 'custom.helpers.indent-info'
cmd('IndentInfo', indent_info.show, { desc = 'Show indentation settings and their origin' })

-- [[ Zoom ]]
local zoom = require 'custom.helpers.zoom'
map('n', '<leader>z', zoom.toggle, { desc = 'Toggle: Zoom current buffer' })

-- [[ Focus: Zen mode ]]
map('n', '<leader>zz', function() require('zen-mode').toggle() end, { desc = 'Toggle: Zen mode' })

-- [[ Markdown preview ]]
local markdown = require 'custom.helpers.glow-markdown'
map('n', '<leader>tm', markdown.preview, { desc = 'Toggle: Markdown preview' })

-- [[ QQ command: AI answers streamed to the nvim buffer ]]
local qq = require 'custom.helpers.qq'
cmd('QQ', qq.run_stream, { nargs = '+', desc = 'Stream a quick answer to a question into the current buffer' })
map('n', '<leader>qq', ':QQ ', { desc = 'AI: Quick Question' })
