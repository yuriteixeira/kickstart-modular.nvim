local ok, base16 = pcall(require, 'base16-colorscheme')

if ok and base16.colors then
  vim.api.nvim_set_hl(0, 'IblIndent', { fg = base16.colors.base01, ctermfg = base16.colors.cterm01 })
else
  vim.api.nvim_set_hl(0, 'IblIndent', { link = 'NonText' })
end

require('ibl').setup {
  indent = {
    char = '╎',
    highlight = 'IblIndent',
  },
}

vim.keymap.set('n', '<leader>i', '<cmd>IBLToggle<cr>', { desc = 'Toggle [I]ndent lines' })
