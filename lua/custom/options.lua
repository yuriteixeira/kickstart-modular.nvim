local graphical = os.getenv 'TERM' ~= 'linux' or os.getenv 'TERM' ~= 'console'

if graphical then vim.g.have_nerd_font = true end

vim.o.termguicolors = true

-- Sane defaults (overridden by .editorconfig when present)
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.fileencoding = 'utf-8'
