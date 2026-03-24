local graphical = os.getenv 'TERM' ~= 'linux' or os.getenv 'TERM' ~= 'console'

if graphical then vim.g.have_nerd_font = true end

vim.o.termguicolors = true
