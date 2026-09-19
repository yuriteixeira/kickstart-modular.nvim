-- Highlight's tweaking
local terminal = require 'custom.helpers.terminal'

if terminal.is_graphical then
  -- Transparent Bg
  -- TODO: Convert to Neovim's Lua API calls (like we see below)
  vim.cmd [[ highlight Normal guibg=none ctermbg=none ]]
  vim.cmd [[ highlight NonText guibg=none ctermbg=none ]]
end

-- Equalize splits on terminal resize
vim.api.nvim_create_autocmd('VimResized', {
  command = 'wincmd =',
})

-- Center the target line after selecting an item from the quickfix/location list.
require('custom.helpers.quickfix').center_selection_on_open()

local eslint_suppressions = require 'custom.helpers.eslint-suppressions'
vim.lsp.config('eslint', {
  handlers = {
    ['textDocument/diagnostic'] = eslint_suppressions.on_diagnostic,
    ['textDocument/publishDiagnostics'] = eslint_suppressions.on_publish_diagnostics,
  },
})

-- pnpm keeps transitive deps only in `node_modules/.pnpm/node_modules`, which pnpm's own
-- `.bin` shims expose via NODE_PATH. The eslint language server isn't started through those
-- shims, so plugins pulled in by shared configs fail
-- to resolve. Hand the server the same NODE_PATH.
local pnpm_root = vim.fs.root(vim.fn.getcwd(), 'pnpm-lock.yaml')

if pnpm_root then
  local hoisted_modules = pnpm_root .. '/node_modules/.pnpm/node_modules'
  local start_eslint = vim.lsp.config.eslint.cmd

  if vim.uv.fs_stat(hoisted_modules) and type(start_eslint) == 'function' then
    vim.lsp.config('eslint', {
      -- `cmd_env` is ignored when a config supplies `cmd` as a function, so wrap the spawn instead.
      cmd = function(dispatchers, config)
        local previous_node_path = vim.env.NODE_PATH
        vim.env.NODE_PATH = hoisted_modules

        local ok, rpc = pcall(start_eslint, dispatchers, config)

        vim.env.NODE_PATH = previous_node_path
        assert(ok, rpc)

        return rpc
      end,
    })
  end
end

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
      callback = function(event) map_css_class_definition(event.buf) end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if #vim.lsp.get_clients { bufnr = bufnr } > 0 then map_css_class_definition(bufnr) end
    end
  end,
})
