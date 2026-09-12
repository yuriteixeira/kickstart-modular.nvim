-- Values consumed while Kickstart plugins are being initialized.
local term = os.getenv 'TERM'
local graphical = term ~= 'linux' and term ~= 'console'

if graphical then vim.g.have_nerd_font = true end
