local M = {}

-- Base16 shell stores these palette entries in ANSI slots 0 through 21.
local slots = { 0, 18, 19, 8, 20, 7, 21, 15, 1, 16, 3, 2, 6, 4, 5, 17 }

function M.read(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil, 'Cannot read the system Base16 palette: ' .. path
  end

  local colors = {}
  -- Read assignments only. Do not execute the shell script or its terminal commands.
  for _, line in ipairs(lines) do
    local name, value = line:match('^%s*(color%d%d)%s*=%s*([^%s#]+)')
    if name then
      value = value:gsub('^["\']', ''):gsub('["\']$', '')
      local reference = value:match('^%$(color%d%d)$') or value:match('^%${(color%d%d)}$')
      colors[name] = reference and colors[reference] or value
    end
  end

  local palette = {}
  for index, slot in ipairs(slots) do
    local value = colors[('color%02d'):format(slot)]
    if not value or not value:match('^%x%x/%x%x/%x%x$') then
      return nil, ('Invalid system Base16 palette entry: color%02d'):format(slot)
    end
    local suffix = ('%02X'):format(index - 1)
    palette['base' .. suffix] = '#' .. value:gsub('/', '')
    palette['cterm' .. suffix] = slot
  end
  return palette
end

return M
