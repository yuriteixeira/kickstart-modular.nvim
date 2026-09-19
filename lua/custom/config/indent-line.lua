local ok, base16 = pcall(require, 'base16-colorscheme')

if (ok) then
  vim.api.nvim_set_hl(0, 'IblIndent', { fg = base16.colors.base01 })
end

require('ibl').setup {
  indent = {
    char = '╎',
    highlight = 'IblIndent',
  },
}

vim.keymap.set('n', '<leader>i', '<cmd>IBLToggle<cr>', { desc = 'Toggle [I]ndent lines' })
