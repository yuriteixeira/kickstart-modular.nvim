local M = {}

local MARKUP_FILETYPES = {
  astro = true,
  html = true,
  javascriptreact = true,
  svelte = true,
  typescriptreact = true,
  vue = true,
}

local STYLESHEET_GLOBS = {
  '*.astro',
  '*.css',
  '*.less',
  '*.pcss',
  '*.postcss',
  '*.sass',
  '*.scss',
  '*.svelte',
  '*.vue',
}

local function is_markup_buffer(bufnr)
  return MARKUP_FILETYPES[vim.bo[bufnr].filetype] == true
end

local function get_workspace_root(bufnr)
  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
    local folders = client.workspace_folders
    if folders and folders[1] and folders[1].name then return folders[1].name end

    local root_dir = client.config and client.config.root_dir
    if root_dir then return root_dir end
  end

  return vim.uv.cwd()
end

local function escape_regex(value)
  return (value:gsub('([\\%(%)%.%%%+%-%*%?%[%]%^%$%{%}%|])', '\\%1'))
end

local function css_escape(value)
  return (value:gsub('([^%w_-])', '\\%1'))
end

local function class_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local delimiter_pattern = "[%s\"'`<>{}=,()]"

  local start_col = col
  while start_col > 1 and not line:sub(start_col - 1, start_col - 1):match(delimiter_pattern) do
    start_col = start_col - 1
  end

  local end_col = col
  while end_col <= #line and not line:sub(end_col, end_col):match(delimiter_pattern) do
    end_col = end_col + 1
  end

  local class_name = line:sub(start_col, end_col - 1):gsub('^%.', ''):gsub('^:', '')
  if class_name == '' or class_name:match '[{}]' then return nil end

  return class_name
end

local function build_rg_args(class_name, root)
  local variants = {
    escape_regex(class_name),
    escape_regex(css_escape(class_name)),
  }
  if variants[1] == variants[2] then table.remove(variants, 2) end

  local pattern = '\\.(' .. table.concat(variants, '|') .. ')([^A-Za-z0-9_-]|$)'

  local args = {
    'rg',
    '--vimgrep',
    '--no-heading',
    '--color',
    'never',
    '--glob',
    '!node_modules',
    '--glob',
    '!dist',
    '--glob',
    '!build',
  }

  for _, glob in ipairs(STYLESHEET_GLOBS) do
    vim.list_extend(args, { '--glob', glob })
  end

  vim.list_extend(args, { pattern, root })
  return args
end

local function first_definition(class_name, root)
  local result = vim.system(build_rg_args(class_name, root), { text = true }):wait()
  if result.code ~= 0 or not result.stdout then return nil end

  local line = vim.split(result.stdout, '\n', { plain = true, trimempty = true })[1]
  if not line then return nil end

  local path, lnum, col = line:match '^(.-):(%d+):(%d+):'
  if not path then return nil end

  return {
    path = path,
    lnum = tonumber(lnum),
    col = tonumber(col),
  }
end

local function open_definition(definition)
  vim.cmd.edit(vim.fn.fnameescape(definition.path))
  vim.api.nvim_win_set_cursor(0, { definition.lnum, math.max(definition.col - 1, 0) })
  vim.cmd 'normal! zz'
end

function M.goto_definition(fallback)
  local bufnr = vim.api.nvim_get_current_buf()
  if is_markup_buffer(bufnr) then
    local class_name = class_at_cursor()
    if class_name and vim.fn.executable 'rg' == 1 then
      local definition = first_definition(class_name, get_workspace_root(bufnr))
      if definition then
        open_definition(definition)
        return
      end
    end
  end

  fallback()
end

return M
