local colors = require('base16-colorscheme').colors

vim.api.nvim_set_hl(0, 'IblIndent', { fg = colors.base01 })

require('ibl').setup {
  indent = {
    char = '╎',
    highlight = 'IblIndent',
  },
}

vim.keymap.set('n', '<leader>i', '<cmd>IBLToggle<cr>', { desc = 'Toggle [I]ndent lines' })
