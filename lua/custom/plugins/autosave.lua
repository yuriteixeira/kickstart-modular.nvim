-- base16-nvim
---@module 'lazy'
---@type LazySpec
return {
  'okuuva/auto-save.nvim',
  version = '^1.0.0',
  cmd = 'ASToggle',
  event = { 'InsertLeave', 'TextChanged' }, -- optional for lazy loading on trigger events
  opts = {
    -- your config goes here
    -- or just leave it empty (REQUIRED)
  },
}
