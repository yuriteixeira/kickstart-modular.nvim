local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/zen-mode.nvim' }
require('zen-mode').setup {
  window = {
    backdrop = 0.95,
    width = 120,
    height = 1,
    options = {
      signcolumn = 'no',
      number = false,
      relativenumber = false,
      cursorline = false,
      cursorcolumn = false,
      foldcolumn = '0',
      list = false,
    },
  },
  plugins = {
    options = {
      enabled = true,
      ruler = false,
      showcmd = false,
      laststatus = 0,
    },
    twilight = { enabled = false },
    gitsigns = { enabled = true },
    todo = { enabled = true },
  },
}

-- vim: ts=2 sts=2 sw=2 et
