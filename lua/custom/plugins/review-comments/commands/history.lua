local storage = require 'custom.plugins.review-comments.storage'
local state = require 'custom.plugins.review-comments.state'
local list = require 'custom.plugins.review-comments.commands.list'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local conf = require('telescope.config').values

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
  local current = storage.path()
  if a.path == current or b.path == current then return a.path == current and b.path ~= current end
  local a_time = a.path:match('%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%-%d+%-?%d*%.json$') or ''
  local b_time = b.path:match('%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%-%d+%-?%d*%.json$') or ''
  if a_time ~= b_time then return a_time > b_time end
  return a.path > b.path
end

local show_history

local function confirm_delete(session)
  local name = vim.fn.fnamemodify(session.path, ':t')
  vim.ui.select({ 'Cancel', 'Delete' }, { prompt = 'Delete review session ' .. name .. '?' }, function(choice)
    if choice ~= 'Delete' then return show_history() end
    local ok, err = pcall(storage.delete_session, session.path)
    if not ok then state.notify(err, vim.log.levels.ERROR) else state.notify('Deleted review session ' .. name) end
    show_history()
  end)
end

local function delete_selection(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  if not entry then return end
  local session = entry.value
  if session.path == storage.path() then return state.notify('Cannot delete the active review session', vim.log.levels.WARN) end
  actions.close(prompt_bufnr)
  confirm_delete(session)
end

local function select_session(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  if entry then open_session(entry.value) end
end

local function make_entry(session)
  return { value = session, display = label(session), ordinal = label(session) }
end

local function open_picker(sessions)
  pickers.new({}, {
    prompt_title = 'Review sessions (Ctrl-D: delete)',
    finder = finders.new_table { results = sessions, entry_maker = make_entry },
    sorter = conf.generic_sorter {},
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(select_session)
      map({ 'i', 'n' }, '<C-d>', delete_selection)
      return true
    end,
  }):find()
end

show_history = function()
  if #state.comments > 0 or vim.fn.filereadable(storage.path()) == 1 then state.flush() end
  local sessions = {}
  for _, path in ipairs(storage.sessions()) do
    local ok, comments = pcall(storage.load, path)
    if not ok then return state.notify(comments, vim.log.levels.ERROR) end
    sessions[#sessions + 1] = { path = path, comments = comments }
  end
  if #sessions == 0 then return state.notify('No saved review sessions') end
  table.sort(sessions, newest_first)
  open_picker(sessions)
end

return show_history
