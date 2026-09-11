-- PERSONAL: Kotlin/Android language support.
vim.lsp.config('jdtls', {})
vim.lsp.enable 'jdtls'

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

-- The official Kotlin LSP currently cannot import Android projects due to an
-- upstream classloader regression (Kotlin/kotlin-lsp#243). The older server
-- works when projects provide a Gradle wrapper and it runs on a compatible JDK.
vim.lsp.config('kotlin_language_server', {
  before_init = configure_kotlin_cache,
  cmd_env = kotlin_server_env(),
})
vim.lsp.enable 'kotlin_language_server'

require('mason-tool-installer').setup {
  ensure_installed = {
    'jdtls',
    'kotlin-language-server',
    'ktlint',
    'google-java-format',
  },
}

require('conform').setup {
  formatters_by_ft = {
    kotlin = { 'ktlint' },
    java = { 'google-java-format' },
  },
}

require('nvim-treesitter').install { 'java', 'kotlin', 'xml' }
