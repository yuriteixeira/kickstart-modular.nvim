-- typescript-tools
---@module 'lazy'
---@type LazySpec

local function pnpm_global_tsserver()
  if vim.fn.executable 'pnpm' ~= 1 then
    return nil
  end

  local pnpm_root = vim.fn.systemlist { 'pnpm', 'root', '-g' }[1]
  if not pnpm_root or pnpm_root == '' then
    return nil
  end

  local tsserver = pnpm_root .. '/typescript/lib/tsserver.js'
  if vim.uv.fs_stat(tsserver) then
    return tsserver
  end

  return nil
end

return {
  'pmizio/typescript-tools.nvim',
  lazy = false,
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  opts = {
    settings = {
      -- typescript-tools only checks `npm root -g` by default.  PNPM's global
      -- store lives elsewhere, so point tsserver at PNPM's global TypeScript.
      tsserver_path = pnpm_global_tsserver(),
    },
  },
}
