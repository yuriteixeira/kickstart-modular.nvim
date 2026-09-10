local buffer = require 'custom.helpers.qq.buffer'
local process = require 'custom.helpers.qq.process'

local M = {}

local handle_stdout
local handle_exit
local notify_error
local notify_warn

function M.run_stream(opts)
  notify_warn 'QQ is thinking...'

  local bufnr = vim.api.nvim_get_current_buf()
  local insertion_row = vim.api.nvim_win_get_cursor(0)[1]

  if not buffer.is_writable(bufnr) then
    notify_error 'QQ cannot write into this buffer'
    return
  end

  local stream = buffer.create(bufnr, insertion_row, notify_error)
  process.start(opts.args, {
    context = stream,
    on_stdout = handle_stdout,
    on_exit = handle_exit,
  })
end

handle_stdout = function(stream, output) buffer.queue(stream, output) end

handle_exit = function(stream, result, stderr)
  buffer.finish(stream)

  if result.code == 0 then notify_warn 'QQ is done!' end

  if result.code ~= 0 then notify_error(stderr ~= '' and stderr or 'QQ exited with code ' .. result.code) end
end

notify_error = function(message) vim.notify(message, vim.log.levels.ERROR) end
notify_warn = function(message) vim.notify(message, vim.log.levels.WARN) end

return M
