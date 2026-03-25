---@module 'lazy'
---@type LazySpec
return {
  {
    'chentoast/marks.nvim',
    event = 'VimEnter',
    config = function()
      require('marks').setup()
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
