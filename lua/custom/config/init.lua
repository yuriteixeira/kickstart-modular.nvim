-- Load personal plugin configurations in an intentional order.
local configurations = {
  'completion',
  'formatting',
  'gitsigns',
  'indent-line',
  'lsp',
  'statusline',
  'telescope',
  'treesitter',
  'which-key',
}

for _, configuration in ipairs(configurations) do
  require('custom.config.' .. configuration)
end
