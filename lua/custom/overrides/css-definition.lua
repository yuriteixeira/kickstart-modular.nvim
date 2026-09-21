local function goto_definition()
  local css_class_definition = require 'custom.helpers.css-class-definition'

  css_class_definition.goto_definition(function()
    local ok, builtin = pcall(require, 'telescope.builtin')
    if ok then
      builtin.lsp_definitions()
    else
      vim.lsp.buf.definition()
    end
  end)
end

local function goto_definition_in_vertical_split()
  vim.cmd 'vsplit'
  goto_definition()
end

local function goto_definition_in_horizontal_split()
  vim.cmd 'split'
  goto_definition()
end

local function map_css_class_definition(bufnr)
  vim.keymap.set('n', 'gd', goto_definition, { buffer = bufnr, desc = '[G]oto [D]efinition' })
  vim.keymap.set('n', 'gdv', goto_definition_in_vertical_split, {
    buffer = bufnr,
    desc = '[G]oto [D]efinition in [V]ertical split',
  })
  vim.keymap.set('n', 'gdh', goto_definition_in_horizontal_split, {
    buffer = bufnr,
    desc = '[G]oto [D]efinition in [H]orizontal split',
  })
end

-- Prefer CSS selector jumps from markup class names, then fall back to normal LSP definitions.
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('custom-css-class-definition-bootstrap', { clear = true }),
  callback = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('custom-css-class-definition', { clear = true }),
      callback = function(event) map_css_class_definition(event.buf) end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if #vim.lsp.get_clients { bufnr = bufnr } > 0 then map_css_class_definition(bufnr) end
    end
  end,
})
