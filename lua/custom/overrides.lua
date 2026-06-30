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

-- Center the target line after selecting an item from the quickfix/location list.
require('custom.helpers.quickfix').center_selection_on_open()

local function map_css_class_definition(bufnr)
  vim.keymap.set('n', 'gd', function()
    local css_class_definition = require 'custom.helpers.css-class-definition'

    css_class_definition.goto_definition(function()
      local ok, builtin = pcall(require, 'telescope.builtin')
      if ok then
        builtin.lsp_definitions()
      else
        vim.lsp.buf.definition()
      end
    end)
  end, { buffer = bufnr, desc = '[G]oto [d]efinition' })
end

-- Prefer CSS selector jumps from markup class names, then fall back to normal LSP definitions.
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('custom-css-class-definition-bootstrap', { clear = true }),
  callback = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('custom-css-class-definition', { clear = true }),
      callback = function(event)
        map_css_class_definition(event.buf)
      end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if #vim.lsp.get_clients { bufnr = bufnr } > 0 then map_css_class_definition(bufnr) end
    end
  end,
})
