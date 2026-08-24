-- Load plugin modules in order.

require 'kickstart.plugins.guess-indent'
require 'kickstart.plugins.gitsigns'
require 'kickstart.plugins.which-key'
require 'kickstart.plugins.todo-comments'
require 'kickstart.plugins.mini'
require 'kickstart.plugins.telescope'
require 'kickstart.plugins.lspconfig'
require 'kickstart.plugins.conform'
require 'kickstart.plugins.blink-cmp'
require 'kickstart.plugins.treesitter'
require 'custom.plugins.base16'
require 'kickstart.plugins.autopairs'
require 'kickstart.plugins.indent_line'
require 'kickstart.plugins.neo-tree'

-- Load the remaining user-specific plugins from lua/custom/plugins/*.lua.
require 'custom.plugins'

-- The following optional examples are available but disabled:
-- require 'kickstart.plugins.debug'
-- require 'kickstart.plugins.lint'

-- vim: ts=2 sts=2 sw=2 et
