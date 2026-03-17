local wayland = os.getenv 'XDG_SESSION_TYPE' == 'wayland' and not os.getenv 'DISPLAY'

if wayland then
  vim.o.termguicolors = true
  vim.g.have_nerd_font = true
  vim.cmd [[ highlight Normal guibg=none ctermbg=none ]]
  vim.cmd [[ highlight NonText guibg=none ctermbg=none ]]
end
