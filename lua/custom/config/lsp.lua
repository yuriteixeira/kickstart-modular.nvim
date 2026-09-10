local function lua_runtime_library()
  local library = vim.api.nvim_get_runtime_file('', true)
  vim.list_extend(library, {
    '${3rd}/luv/library',
    '${3rd}/busted/library',
  })
  return library
end

local function configure_lua(client)
  client.server_capabilities.documentFormattingProvider = false

  if client.workspace_folders then
    local path = client.workspace_folders[1].name
    local has_lua_config = vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')
    if path ~= vim.fn.stdpath 'config' and has_lua_config then return end
  end

  client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua or {}, {
    runtime = {
      version = 'LuaJIT',
      path = { 'lua/?.lua', 'lua/?/init.lua' },
    },
    workspace = {
      checkThirdParty = false,
      library = lua_runtime_library(),
    },
  })
end

---@type table<string, vim.lsp.Config>
local servers = {
  pyright = {},
  ruff = {},
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        cargo = { features = 'all' },
        check = { command = 'clippy' },
      },
    },
  },
  html = {},
  cssls = {
    settings = {
      css = { lint = { unknownAtRules = 'ignore' } },
      scss = { lint = { unknownAtRules = 'ignore' } },
      less = { lint = { unknownAtRules = 'ignore' } },
    },
  },
  tailwindcss = {
    filetypes = {
      'astro',
      'css',
      'html',
      'javascript',
      'javascriptreact',
      'svelte',
      'typescript',
      'typescriptreact',
      'vue',
    },
    settings = {
      tailwindCSS = {
        classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass' },
        validate = true,
      },
    },
  },
  svelte = {},
  somesass_ls = {},
  eslint = {},
  bashls = {},
  lua_ls = {
    on_init = configure_lua,
    settings = {
      Lua = {
        format = { enable = false },
      },
    },
  },
}

require('mason.settings').set {
  pip = {
    install_args = { '--index-url', 'https://pypi.org/simple/' },
  },
}

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, {
  'stylua',
  'prettier',
  'beautysh',
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end
