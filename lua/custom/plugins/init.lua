-- Load personal plugins in an intentional order.
local plugins = {
  'base16',
  'autosave',
  'diffconflicts',
  'marks',
  'nvim-ts-autotag',
  'outline',
  'review-comments',
  'typescript',
  'zen-mode',
}

for _, plugin in ipairs(plugins) do
  require('custom.plugins.' .. plugin)
end
