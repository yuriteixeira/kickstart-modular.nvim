local state = require 'custom.plugins.review-comments.state'
local storage = require 'custom.plugins.review-comments.storage'

local M = {}

local function confirm(prompt, clear)
  vim.ui.select({ 'Cancel', 'Clear' }, { prompt = prompt }, function(choice)
    if choice ~= 'Clear' then return end
    local ok, err = pcall(clear)
    if not ok then state.notify(err, vim.log.levels.ERROR) end
  end)
end

function M.file()
  local path = state.buffer_path(0)
  if not path then return state.notify('No file to clear', vim.log.levels.WARN) end
  local count = 0
  for _, comment in ipairs(state.comments) do
    if comment.path == path then count = count + 1 end
  end
  if count == 0 then return state.notify('No review comments in this file') end
  confirm('Clear ' .. count .. ' review comments in ' .. state.display_path(path) .. '?', function()
    state.clear_file(path)
    state.notify('Cleared review comments in ' .. state.display_path(path))
  end)
end

function M.session()
  local count = #state.comments
  if count == 0 then return state.notify('No review comments in this session') end
  confirm('Clear ' .. count .. ' review comments in the current session?', function()
    state.clear_session()
    state.notify('Cleared review comments in the current session')
  end)
end

function M.store()
  local count = #storage.sessions()
  if count == 0 then return state.notify('No saved review sessions') end
  confirm('Delete ' .. count .. ' saved review sessions across all projects and reset active sessions?', function()
    state.clear_store()
    state.notify('Cleared the review comment store')
  end)
end

return M
