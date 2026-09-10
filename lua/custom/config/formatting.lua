require('conform').setup {
  format_on_save = nil,
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_format' },
    css = { 'prettier' },
    html = { 'prettier' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    svelte = { 'prettier' },
    sh = { 'beautysh' },
    zsh = { 'beautysh' },
    bash = { 'beautysh' },
    rust = { 'rustfmt' },
  },
}

vim.keymap.del({ 'n', 'v' }, '<leader>f')
vim.keymap.set({ 'n', 'v' }, '<leader>p', function() require('conform').format { async = true, lsp_format = 'fallback' } end, { desc = '[P]rettify buffer' })
