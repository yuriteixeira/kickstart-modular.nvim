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
