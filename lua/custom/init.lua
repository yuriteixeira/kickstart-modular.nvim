-- Keep personal configuration behind this single upstream integration point.
-- Upstream-owned files should remain unchanged except for `require 'custom'`
-- in `lua/plugins.lua`.

require 'custom.options'
require 'custom.commands'

-- Enable optional plugins shipped by Kickstart without editing its loader.
require 'kickstart.plugins.autopairs'
require 'kickstart.plugins.indent_line'
require 'kickstart.plugins.neo-tree'

require 'custom.keymaps'
require 'custom.plugins'
require 'custom.config'
require 'custom.overrides'
