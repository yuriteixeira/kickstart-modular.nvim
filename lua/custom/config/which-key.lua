require('which-key').setup {
  delay = 300,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>f', group = '[F]ind', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}
