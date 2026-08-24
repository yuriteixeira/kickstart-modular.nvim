local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Formatting ]]
vim.pack.add { gh 'stevearc/conform.nvim' }
require('conform').setup {
  notify_on_error = false,
  format_on_save = nil,
  default_format_opts = {
    lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
  },
  -- You can also specify external formatters in here.
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
    -- rust = { 'rustfmt' },
    -- Conform can also run multiple formatters sequentially
    -- python = { "isort", "black" },
    --
    -- You can use 'stop_after_first' to run the first available formatter from the list
    -- javascript = { "prettierd", "prettier", stop_after_first = true },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>p', function() require('conform').format { async = true, lsp_format = 'fallback' } end, { desc = '[P]rettify buffer' })

-- vim: ts=2 sts=2 sw=2 et
