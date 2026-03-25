-- Add indentation guides even on blank lines

---@module 'lazy'
---@type LazySpec
return {
  'lukas-reineke/indent-blankline.nvim',
  -- Enable `lukas-reineke/indent-blankline.nvim`
  -- See `:help ibl`
  main = 'ibl',
  ---@module 'ibl'
  ---@type ibl.config
  opts = {
    indent = {
      char = '╎',
      highlight = 'IblIndent',
    },
  },
  config = function(_, opts)
    local colors = require('base16-colorscheme').colors
    vim.api.nvim_set_hl(0, 'IblIndent', { fg = colors.base01 })
    require('ibl').setup(opts)
    vim.keymap.set('n', '<leader>i', '<cmd>IBLToggle<cr>', { desc = 'Toggle [I]ndent lines' })
  end,
}
