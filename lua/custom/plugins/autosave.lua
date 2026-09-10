local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { { src = gh 'okuuva/auto-save.nvim', version = vim.version.range '1.*' } }
require('auto-save').setup {}
