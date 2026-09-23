local map = vim.keymap.set

local function toggle_spell_checking()
  vim.wo.spell = not vim.wo.spell
  vim.notify('Spell checking ' .. (vim.wo.spell and 'enabled' or 'disabled'))
end

map('n', '<leader><leader>', ':b#<CR>', { desc = 'Buffers: Toggle current buffer with last opened one' })
map('n', '<leader>ww', ':w<CR>', { desc = 'File: Save' })
map('n', '<leader>to', ':Outline<CR>', { desc = 'Toggle: Outline' })
map('n', '<leader>ts', toggle_spell_checking, { desc = 'Toggle: Spell checking' })

-- [[ File path ]]
map('n', '<leader>fp', ':RelativeFilePath<CR>', { desc = 'File: Copy relative file path' })
map('n', '<leader>fP', ':FilePath<CR>', { desc = 'File: Copy absolute file path' })

-- [[ Diagnostics ]]
local diagnostics = require 'custom.helpers.diagnostics'

map('n', '<leader>td', diagnostics.toggle_inline, { desc = 'Toggle: Inline diagnostics' })

map('n', '<leader>q', function() vim.diagnostic.setloclist { format = diagnostics.format } end, { desc = 'Open diagnostic [Q]uickfix list' })

-- [[ Zoom ]]
local zoom = require 'custom.helpers.zoom'
map('n', '<leader>z', zoom.toggle, { desc = 'Toggle: Zoom current buffer' })

-- [[ Zen mode: Focus ]]
map('n', '<leader>zz', function() require('zen-mode').toggle() end, { desc = 'Toggle: Zen mode' })

-- [[ Markdown preview ]]
local markdown = require 'custom.helpers.glow-markdown'
map('n', '<leader>tm', markdown.preview, { desc = 'Toggle: Markdown preview' })

-- [[ QQ command: AI answers streamed to the nvim buffer ]]
map('n', '<leader>QQ', ':QQ ', { desc = 'AI: Quick Question' })

-- [[ Command history ]]
map('n', '<leader>f;', ':Telescope command_history<CR>', { desc = 'Search command history' })
