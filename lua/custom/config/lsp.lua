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

  local path = client.workspace_folders and client.workspace_folders[1].name
  local has_lua_config = path and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
  if path and path ~= vim.fn.stdpath 'config' and has_lua_config then return end

  local workspace = { checkThirdParty = false }
  -- Only index Neovim's runtime and plugins for the Neovim config itself.
  -- Including them in every Lua project makes lua_ls scan a large workspace.
  if path == vim.fn.stdpath 'config' then workspace.library = lua_runtime_library() end

  client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua or {}, {
    runtime = {
      version = 'LuaJIT',
      path = { 'lua/?.lua', 'lua/?/init.lua' },
    },
    workspace = workspace,
  })
end

-- Android/Kotlin LSP configuration.
local kotlin_java_home = '/usr/lib/jvm/java-21-openjdk'

local function kotlin_server_env()
  if vim.fn.isdirectory(kotlin_java_home) == 0 then return nil end
  return {
    JAVA_HOME = kotlin_java_home,
    PATH = kotlin_java_home .. '/bin:' .. vim.env.PATH,
  }
end

local function configure_kotlin_cache(params)
  local root_dir = vim.uri_to_fname(params.rootUri)
  local cache_key = vim.fn.sha256(root_dir):sub(1, 16)
  local storage_path = vim.fn.stdpath 'cache' .. '/kotlin-language-server/' .. cache_key
  vim.fn.mkdir(storage_path, 'p')
  params.initializationOptions = vim.tbl_deep_extend('force', params.initializationOptions or {}, {
    storagePath = storage_path,
  })
end

local function disable_kotlin_document_highlight(client)
  -- Workaround for https://github.com/fwcd/kotlin-language-server/issues/600.
  -- The crash protection landed in #612, but is not in Mason's 1.3.13 release;
  -- track https://github.com/fwcd/kotlin-language-server/issues/671 and remove
  -- this workaround once a release containing #612 is available.
  client.server_capabilities.documentHighlightProvider = false
end

vim.lsp.config('jdtls', {})
vim.lsp.config('kotlin_language_server', {
  before_init = configure_kotlin_cache,
  on_init = disable_kotlin_document_highlight,
  cmd_env = kotlin_server_env(),
})

---@type table<string, vim.lsp.Config>
local lsp_servers = {
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

-- LSP servers are configured separately from non-LSP tools such as
-- formatters. Both groups are installed by Mason, but only the former belong
-- in vim.lsp.config(). The Android LSP configs are registered above.
local mason_lsp_servers = {
  'jdtls',
  'kotlin-language-server',
}

local mason_tools = {
  'stylua',
  'prettier',
  'beautysh',
  'ktlint',
  'google-java-format',
}

local ensure_installed = vim.tbl_keys(lsp_servers)
vim.list_extend(ensure_installed, mason_lsp_servers)
vim.list_extend(ensure_installed, mason_tools)
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, config in pairs(lsp_servers) do
  vim.lsp.config(name, config)
end

-- Mason is the source of truth for installed LSPs.
-- Enable them automatically when present.
require('mason-lspconfig').setup {
  automatic_enable = true,
}

-- Guarantees reinstalling everything on a fresh ~/.local/share/nvim installation.
require('mason-tool-installer').run_on_start()
