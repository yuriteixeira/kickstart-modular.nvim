local isWayland = os.getenv 'XDG_SESSION_TYPE' == 'wayland' and not os.getenv 'DISPLAY'

if isWayland then
  vim.o.termguicolors = true
  vim.g.have_nerd_font = true
end
