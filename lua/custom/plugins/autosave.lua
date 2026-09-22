local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { { src = gh 'okuuva/auto-save.nvim', version = vim.version.range '1.*' } }
require('auto-save').setup {
  -- LSP operations can edit files in hidden buffers, such as TypeScript rename.
  -- Save every modified buffer so those workspace edits reach disk.
  write_all_buffers = true,
}
