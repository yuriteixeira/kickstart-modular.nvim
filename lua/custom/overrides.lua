local graphical = os.getenv 'TERM' ~= 'linux'

if graphical then
  vim.cmd [[ highlight Normal guibg=none ctermbg=none ]]
  vim.cmd [[ highlight NonText guibg=none ctermbg=none ]]
end
