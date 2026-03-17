local graphical = os.getenv 'TERM' ~= 'linux'

if graphical then
  vim.o.termguicolors = true
  vim.g.have_nerd_font = true
end
