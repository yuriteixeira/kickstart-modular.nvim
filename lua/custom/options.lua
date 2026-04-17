-- Icons and such will show only when a graphical env is up 
local graphical = os.getenv 'TERM' ~= 'linux' or os.getenv 'TERM' ~= 'console'

if graphical then vim.g.have_nerd_font = true end

-- Needed to make it play well with base16 shell themes even in "no gui" console
vim.o.termguicolors = true

-- Sane defaults (overridden by .editorconfig when present)
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.fileencoding = 'utf-8'

-- Use rounded borders for floating windows such as LSP hover, diagnostics, and popup docs.
vim.o.winborder = 'rounded'

-- Diagnostic Config & Keymaps (:help vim.diagnostic.Opts)
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}
