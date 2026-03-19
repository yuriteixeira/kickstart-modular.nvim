-- Highlight's tweaking
local graphical = os.getenv 'TERM' ~= 'linux' or os.getenv 'TERM' ~= 'console'

if graphical then
  -- Transparent Bg
  -- TODO: Convert to Neovim's Lua API calls (like we see below)
  vim.cmd [[ highlight Normal guibg=none ctermbg=none ]]
  vim.cmd [[ highlight NonText guibg=none ctermbg=none ]]
else
  -- Non-graphical highlight override (since it has only 8 colors, beyond base16)
  vim.api.nvim_set_hl(0, 'Visual', { bg = 'gray', fg = 'white', bold = true })
  vim.api.nvim_set_hl(0, 'VisualNOS', { bg = 'gray', fg = 'white', bold = true })
end

-- Equalize splits on terminal resize
vim.api.nvim_create_autocmd('VimResized', {
  command = 'wincmd =',
})

