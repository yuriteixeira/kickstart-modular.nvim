vim.filetype.add {
  extension = {
    sh = 'bash',
  },
}

-- The Linux console does not support RGB color sequences.
local terminal = require 'custom.helpers.terminal'
vim.o.termguicolors = terminal.is_graphical

-- Sane defaults (overridden by .editorconfig when present)
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.fileencoding = 'utf-8'
vim.o.scrolloff = 0

-- Keep underscores and dashes within words for motions and text objects.
vim.opt.iskeyword:append { '_', '-' }

-- Use rounded borders for floating windows such as LSP hover, diagnostics, and popup docs.
vim.o.winborder = 'rounded'

-- Check writing against American English and Brazilian Portuguese dictionaries.
vim.opt.spelllang = { 'en_us', 'pt_br' }

local spell_check_group = vim.api.nvim_create_augroup('custom-spell-check', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = spell_check_group,
  pattern = { 'gitcommit', 'markdown', 'text' },
  command = 'setlocal spell',
  desc = 'Enable spell checking in writing buffers',
})

-- Diagnostic Config & Keymaps (:help vim.diagnostic.Opts)
local diagnostics = require 'custom.helpers.diagnostics'

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = true,
    suffix = diagnostics.code_suffix,
  },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = diagnostics.inline_options(), -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}
