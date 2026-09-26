local storage = require 'custom.plugins.review-comments.storage'
local state = require 'custom.plugins.review-comments.state'
local list = require 'custom.plugins.review-comments.commands.list'

local function label(session)
  local name = vim.fn.fnamemodify(session.path, ':t')
  local first = session.comments[1]
  local location = first and first.path or 'No comments'
  local current = session.path == storage.path() and ' (current)' or ''
  return name .. current .. ' (' .. #session.comments .. ' comments) - ' .. location
end

local function open_session(session)
  if session then list(session.comments, 'Review comments in ' .. vim.fn.fnamemodify(session.path, ':t')) end
end

local function newest_first(a, b)
  local a_time = a.path:match('%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%-%d+%-?%d*%.json$') or ''
  local b_time = b.path:match('%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%-%d+%-?%d*%.json$') or ''
  if a_time ~= b_time then return a_time > b_time end
  return a.path > b.path
end

return function()
  if #state.comments > 0 or vim.fn.filereadable(storage.path()) == 1 then state.flush() end
  local sessions = {}
  for _, path in ipairs(storage.sessions()) do
    local ok, comments = pcall(storage.load, path)
    if not ok then return state.notify(comments, vim.log.levels.ERROR) end
    sessions[#sessions + 1] = { path = path, comments = comments }
  end
  if #sessions == 0 then return state.notify('No saved review sessions') end
  table.sort(sessions, newest_first)
  vim.ui.select(sessions, { prompt = 'Review sessions', format_item = label }, open_session)
end
