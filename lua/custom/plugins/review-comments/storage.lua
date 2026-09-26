local M = {}

local cwd = vim.fn.getcwd()
local directory = vim.fn.stdpath 'data' .. '/review-comments'
local path = directory .. '/' .. vim.fn.fnamemodify(cwd, ':t') .. '-' .. vim.fn.sha256(cwd):sub(1, 12) .. '.json'

local function session_path() return path end

function M.path() return session_path() end
function M.root() return cwd end

function M.sessions()
  local paths = vim.fn.globpath(directory, '*.json', false, true)
  table.sort(paths)
  return paths
end

function M.load(path)
  path = path or session_path()
  if vim.fn.filereadable(path) == 0 then return {} end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then error('Cannot read review comments: ' .. path) end
  local decoded, data = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not decoded or type(data) ~= 'table' or type(data.comments) ~= 'table' then
    error('Invalid review comments file (not overwritten): ' .. path)
  end
  return data.comments
end

function M.save(comments)
  local path = session_path()
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  local temp = path .. '.' .. vim.fn.getpid() .. '.tmp'
  local ok, err = pcall(vim.fn.writefile, { vim.json.encode { comments = comments } }, temp)
  if not ok then error('Cannot save review comments: ' .. tostring(err)) end
  local renamed, rename_err = vim.uv.fs_rename(temp, path)
  if not renamed then
    vim.fn.delete(temp)
    error('Cannot replace review comments: ' .. tostring(rename_err))
  end
end

return M
