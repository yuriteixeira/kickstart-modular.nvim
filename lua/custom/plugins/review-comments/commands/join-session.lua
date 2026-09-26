local state = require 'custom.plugins.review-comments.state'
local storage = require 'custom.plugins.review-comments.storage'

local create = {}

local function label(session)
  if session == create then return 'Create new session' end
  local name = vim.fn.fnamemodify(session, ':t')
  return name .. (session == storage.path() and ' (current)' or '')
end

local function activate(path, move)
  local ok, err = pcall(state.join_session, path, move)
  if not ok then return state.notify(err, vim.log.levels.ERROR) end
  state.notify('Active review session: ' .. vim.fn.fnamemodify(path, ':t'))
end

local function choose_move(path)
  if path == storage.path() then return state.notify('This session is already active') end
  if #state.comments == 0 then return activate(path, false) end
  vim.ui.select({ 'Move current comments', 'Leave current comments' }, {
    prompt = 'Comments in the current session',
  }, function(choice)
    if choice then activate(path, choice == 'Move current comments') end
  end)
end

local function create_session()
  local suggested = vim.fn.fnamemodify(storage.root(), ':t')
  vim.ui.input({ prompt = 'New review session alias: ', default = suggested }, function(input)
    if input == nil then return end
    local alias = vim.trim(input):lower():gsub('[^%w_-]+', '-'):gsub('^%-+', ''):gsub('%-+$', '')
    if alias == '' then return state.notify('Session alias cannot be empty', vim.log.levels.WARN) end
    choose_move(storage.new_path(alias))
  end)
end

return function()
  local sessions = { create }
  vim.list_extend(sessions, storage.sessions())
  vim.ui.select(sessions, { prompt = 'Join review session', format_item = label }, function(session)
    if session == create then return create_session() end
    if session then choose_move(session) end
  end)
end
