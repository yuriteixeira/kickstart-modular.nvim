-- Neovim hides diagnostic attribution by default when only one source is present.
-- Keep both the producer (for example, eslint) and its rule code visible.
local M = {}

local inline_options = {
  source = true,
  suffix = function(diagnostic) return diagnostic.code and (' [%s]'):format(diagnostic.code) or '' end,
}

function M.inline_options() return inline_options end

function M.code_suffix(diagnostic) return diagnostic.code and (' [%s]'):format(diagnostic.code) or '' end

-- Location lists do not inherit the float/virtual-text source formatting.
function M.format(diagnostic)
  local origin = {}
  if diagnostic.source then table.insert(origin, diagnostic.source) end
  if diagnostic.code then table.insert(origin, diagnostic.code) end

  local prefix = #origin > 0 and ('[%s] '):format(table.concat(origin, ' ')) or ''
  return prefix .. diagnostic.message
end

function M.toggle_inline()
  local enabled = not vim.diagnostic.config().virtual_text
  vim.diagnostic.config { virtual_text = enabled and inline_options or false }
  vim.notify('Inline diagnostics ' .. (enabled and 'enabled' or 'disabled'))
end

return M
