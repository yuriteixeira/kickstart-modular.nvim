-- ESLint 9 applies bulk suppressions only in its CLI; the language server uses
-- the Node API and otherwise reports violations hidden by eslint-suppressions.json.
-- These handlers mirror the CLI behavior without starting a slow CLI process on every change.
local M = {}

-- Diagnostics arrive on each edit, so avoid reparsing an unchanged suppression file.
local cache = {}

local function load_suppressions(bufnr)
  local root = vim.fs.root(bufnr, 'eslint-suppressions.json')
  if not root then return end

  local path = root .. '/eslint-suppressions.json'
  local stat = vim.uv.fs_stat(path)
  if not stat then return end

  local cached = cache[path]
  local version = ('%d:%d:%d'):format(stat.size, stat.mtime.sec, stat.mtime.nsec)
  if cached and cached.version == version then return root, cached.suppressions end

  local ok, suppressions = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), '\n'))
  if not ok then
    vim.notify_once('Could not parse ' .. path, vim.log.levels.ERROR)
    return
  end

  cache[path] = { version = version, suppressions = suppressions }
  return root, suppressions
end

local function relative_path(root, uri)
  local filename = vim.fs.normalize(vim.uri_to_fname(uri))
  return vim.fs.relpath(root, filename)
end

function M.filter(uri, diagnostics)
  local bufnr = vim.uri_to_bufnr(uri)
  local root, suppressions = load_suppressions(bufnr)
  if not root then return diagnostics end

  local rules = suppressions[relative_path(root, uri)]
  if not rules then return diagnostics end

  local error_counts = {}
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.lsp.protocol.DiagnosticSeverity.Error and diagnostic.code then
      local rule = tostring(diagnostic.code)
      error_counts[rule] = (error_counts[rule] or 0) + 1
    end
  end

  local suppressed_rules = {}
  -- ESLint's threshold is all-or-nothing per rule: when the current error count
  -- exceeds the recorded count, every violation for that rule becomes visible.
  for rule, violations in pairs(error_counts) do
    local suppression = rules[rule]
    if suppression and violations <= suppression.count then suppressed_rules[rule] = true end
  end

  return vim.tbl_filter(function(diagnostic) return not diagnostic.code or not suppressed_rules[tostring(diagnostic.code)] end, diagnostics)
end

-- The current ESLint server uses pull diagnostics; the push handler below keeps
-- this compatible with servers that still publish diagnostics.
function M.on_diagnostic(error, result, context, config)
  if result and result.kind == 'full' then
    result = vim.deepcopy(result)
    result.items = M.filter(context.params.textDocument.uri, result.items)

    for uri, report in pairs(result.relatedDocuments or {}) do
      if report.kind == 'full' then report.items = M.filter(uri, report.items) end
    end
  end

  return vim.lsp.diagnostic.on_diagnostic(error, result, context, config)
end

function M.on_publish_diagnostics(error, result, context, config)
  if result then
    result = vim.deepcopy(result)
    result.diagnostics = M.filter(result.uri, result.diagnostics)
  end

  return vim.lsp.diagnostic.on_publish_diagnostics(error, result, context, config)
end

return M
