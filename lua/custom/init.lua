-- Keep personal configuration behind this single upstream integration point.
-- Upstream-owned files should remain unchanged except for `require 'custom'`
-- in `lua/plugins.lua`.

require 'custom.options'
require 'custom.commands'

-- Personal plugins are loaded explicitly because their order can matter.
local plugins = {
  'base16',
  'autosave',
  'diffconflicts',
  'marks',
  'nvim-ts-autotag',
  'outline',
  'typescript',
  'zen-mode',
}

for _, plugin in ipairs(plugins) do
  require('custom.plugins.' .. plugin)
end

-- Enable optional plugins shipped by Kickstart without editing its loader.
require 'kickstart.plugins.autopairs'
require 'kickstart.plugins.indent_line'
require 'kickstart.plugins.neo-tree'

-- Apply personal settings after Kickstart has initialized its plugins.
local configurations = {
  'completion',
  'formatting',
  'gitsigns',
  'indent-line',
  'lsp',
  'regrafter',
  'statusline',
  'telescope',
  'treesitter',
  'which-key',
}

for _, configuration in ipairs(configurations) do
  require('custom.config.' .. configuration)
end

require 'custom.keymaps'
require 'custom.overrides'
