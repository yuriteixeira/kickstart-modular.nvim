local parsers = {
  'json',
  'javascript',
  'jsx',
  'python',
  'rust',
  'svelte',
  'tsx',
  'typescript',
}

vim.treesitter.language.register('json', 'jsonl')
require('nvim-treesitter').install(parsers)
