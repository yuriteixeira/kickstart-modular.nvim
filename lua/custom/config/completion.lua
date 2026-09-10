local function gh(repo) return 'https://github.com/' .. repo end

local completion_sources = { 'lsp', 'path', 'snippets', 'buffer' }

local function show_all_sources(cmp)
  if not cmp.is_menu_visible() then return cmp.show { providers = completion_sources } end
end

vim.pack.add { gh 'rafamadriz/friendly-snippets' }
require('luasnip.loaders.from_vscode').lazy_load()

-- blink.cmp only accepts its public setup call once. Merge the personal layer
-- into the active configuration, then register the resulting keymaps.
require('blink.cmp.config').merge_with {
  keymap = {
    preset = 'enter',
    ['<C-Space>'] = {
      show_all_sources,
      'show_documentation',
      'hide_documentation',
    },
    ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
  },
  sources = {
    default = completion_sources,
    providers = {
      lsp = { fallbacks = {} },
      path = { fallbacks = {} },
    },
  },
}
require('blink.cmp.keymap').setup()
