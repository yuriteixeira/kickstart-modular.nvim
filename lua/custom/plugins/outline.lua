-- outline
---@module 'lazy'
---@type LazySpec
return {
  'hedyhli/outline.nvim',
  lazy = false,
  config = function()
    require('outline').setup {
      -- Your setup opts here (leave empty to use defaults)
    }
  end,
}
