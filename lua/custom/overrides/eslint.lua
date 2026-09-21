local eslint_suppressions = require 'custom.helpers.eslint-suppressions'

vim.lsp.config('eslint', {
  handlers = {
    ['textDocument/diagnostic'] = eslint_suppressions.on_diagnostic,
    ['textDocument/publishDiagnostics'] = eslint_suppressions.on_publish_diagnostics,
  },
})

-- pnpm keeps transitive deps only in `node_modules/.pnpm/node_modules`, which pnpm's own
-- `.bin` shims expose via NODE_PATH. The eslint language server isn't started through those
-- shims, so plugins pulled in by shared configs fail to resolve. Hand the server the same NODE_PATH.
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
