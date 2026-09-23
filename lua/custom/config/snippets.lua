local luasnip = require 'luasnip'
local insert_node = luasnip.insert_node
local snippet = luasnip.snippet
local text_node = luasnip.text_node

luasnip.add_snippets('all', {
  snippet('todo', { text_node '- [ ] ', insert_node(1) }),
})
