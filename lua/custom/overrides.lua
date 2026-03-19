local graphical = os.getenv 'TERM' ~= 'linux'

if graphical then
  -- TODO: Convert to Neovim's Lua API calls (like we see below)
  vim.cmd [[ highlight Normal guibg=none ctermbg=none ]]
  vim.cmd [[ highlight NonText guibg=none ctermbg=none ]]
else
  vim.api.nvim_set_hl(0, 'Visual', { bg = 'gray', fg = 'white', bold = true })
  vim.api.nvim_set_hl(0, 'VisualNOS', { bg = 'gray', fg = 'white', bold = true })
end

-- Equalize splits on terminal resize
vim.api.nvim_create_autocmd('VimResized', {
  command = 'wincmd =',
})

