-- Load personal plugin configurations in an intentional order.
local configurations = {
  'completion',
  'formatting',
  'gitsigns',
  'indent-line',
  'lsp',
  'snippets',
  'statusline',
  'telescope',
  'treesitter',
  'which-key',
}

for _, configuration in ipairs(configurations) do
  require('custom.config.' .. configuration)
end
