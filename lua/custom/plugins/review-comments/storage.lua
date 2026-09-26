local M = {}

local cwd = vim.fn.getcwd()
local directory = vim.fn.stdpath 'data' .. '/review-comments'
local name = vim.fn.fnamemodify(cwd, ':t')
local root_hash = vim.fn.sha256(cwd):sub(1, 12)
local active_file = directory .. '/' .. root_hash .. '.active'
local path

local function new_path(alias)
  local stem = directory .. '/' .. alias .. '-' .. root_hash .. '-' .. os.date('%Y%m%d-%H%M%S') .. '-' .. vim.fn.getpid()
  local candidate = stem .. '.json'
  local index = 1
  while candidate == path or vim.uv.fs_stat(candidate) do
    candidate = stem .. '-' .. index .. '.json'
    index = index + 1
  end
  return candidate
end

function M.sessions()
  local paths = vim.fn.globpath(directory, '*.json', false, true)
  table.sort(paths)
  return paths
end

local function startup_path()
  if vim.fn.filereadable(active_file) == 1 then
    local chosen = vim.fn.readfile(active_file)[1]
    if chosen and vim.fn.filereadable(chosen) == 1 then return chosen end
  end

  local newest, newest_time
  for _, candidate in ipairs(M.sessions()) do
    local filename = vim.fn.fnamemodify(candidate, ':t')
    local timestamp = filename:match('%-' .. root_hash .. '%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%-%d+%-?%d*%.json$')
    if timestamp and (not newest_time or timestamp > newest_time or (timestamp == newest_time and candidate > newest)) then
      newest, newest_time = candidate, timestamp
    end
  end
  if newest then return newest end

  local legacy = directory .. '/' .. name .. '-' .. root_hash .. '.json'
  if vim.fn.filereadable(legacy) == 1 then return legacy end
  return new_path(name:lower():gsub('[^%w_-]+', '-'))
end

path = startup_path()

function M.path() return path end
function M.root() return cwd end
function M.new_path(alias) return new_path(alias) end

local function remember(selected)
  vim.fn.mkdir(directory, 'p')
  local temp = active_file .. '.' .. vim.fn.getpid() .. '.tmp'
  local ok, err = pcall(vim.fn.writefile, { selected }, temp)
  if not ok then error('Cannot remember review session: ' .. tostring(err)) end
  local renamed, rename_err = vim.uv.fs_rename(temp, active_file)
  if not renamed then
    vim.fn.delete(temp)
    error('Cannot remember review session: ' .. tostring(rename_err))
  end
end

function M.set_path(selected)
  remember(selected)
  path = selected
end

function M.load(selected)
  selected = selected or path
  if vim.fn.filereadable(selected) == 0 then return {} end
  local ok, lines = pcall(vim.fn.readfile, selected)
  if not ok then error('Cannot read review comments: ' .. selected) end
  local decoded, data = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not decoded or type(data) ~= 'table' or type(data.comments) ~= 'table' then
    error('Invalid review comments file (not overwritten): ' .. selected)
  end
  return data.comments
end

function M.save(comments, selected)
  selected = selected or path
  vim.fn.mkdir(vim.fn.fnamemodify(selected, ':h'), 'p')
  local temp = selected .. '.' .. vim.fn.getpid() .. '.tmp'
  local ok, err = pcall(vim.fn.writefile, { vim.json.encode { comments = comments } }, temp)
  if not ok then error('Cannot save review comments: ' .. tostring(err)) end
  local renamed, rename_err = vim.uv.fs_rename(temp, selected)
  if not renamed then
    vim.fn.delete(temp)
    error('Cannot replace review comments: ' .. tostring(rename_err))
  end
  if selected == path and vim.fn.filereadable(active_file) == 0 then remember(path) end
end

return M
