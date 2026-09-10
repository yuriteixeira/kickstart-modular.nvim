local M = {}

local qq_shell_command = 'source "$HOME/.zshrc_helpers"; qq "$@"'

local handle_stdout
local handle_stderr
local handle_exit
local append

function M.start(question, handlers)
  local state = {
    handlers = handlers,
    stderr = {},
  }
  local command = { 'zsh', '-fc', qq_shell_command, 'qq', question }

  vim.system(command, {
    text = true,
    stdout = function(err, data) handle_stdout(state, err, data) end,
    stderr = function(err, data) handle_stderr(state, err, data) end,
  }, vim.schedule_wrap(function(result) handle_exit(state, result) end))
end

handle_stdout = function(state, err, data)
  append(state.stderr, err)
  if data then state.handlers.on_stdout(state.handlers.context, data) end
end

handle_stderr = function(state, err, data)
  append(state.stderr, err)
  append(state.stderr, data)
end

handle_exit = function(state, result) state.handlers.on_exit(state.handlers.context, result, table.concat(state.stderr)) end

append = function(items, value)
  if value then table.insert(items, value) end
end

return M
