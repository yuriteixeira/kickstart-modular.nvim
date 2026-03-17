-- base16-nvim
---@module 'lazy'
---@type LazySpec
return {
  'RRethy/base16-nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('base16-colorscheme').with_config {
      telescope = true,
      telescope_borders = true,
      indentblankline = true,
      notify = true,
      ts_rainbow = true,
      cmp = true,
      illuminate = true,
      lsp_semantic = true,
      mini_completion = true,
      dapui = true,
      diffview = true,
    }

    vim.cmd 'colorscheme base16-atelier-lakeside'
  end,
}
