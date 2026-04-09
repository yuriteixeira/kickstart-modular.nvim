--  nvim-ts-autotag
---@module 'lazy'
---@type LazySpec
return {
  'windwp/nvim-ts-autotag',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {},
}
