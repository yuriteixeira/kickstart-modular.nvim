local M = {}

local stream_namespace = vim.api.nvim_create_namespace 'custom-qq-stream'

local flush
local fail

function M.is_writable(bufnr) return vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modifiable end

function M.create(bufnr, insertion_row, on_error)
  vim.api.nvim_buf_set_lines(bufnr, insertion_row, insertion_row, false, { '' })

  local mark_id = vim.api.nvim_buf_set_extmark(bufnr, stream_namespace, insertion_row, 0, { right_gravity = true })

  return {
    bufnr = bufnr,
    mark_id = mark_id,
    flush_scheduled = false,
    insert_failed = false,
    pending_output = {},
    on_error = on_error,
  }
end

function M.queue(stream, output)
  if output == '' then return end

  table.insert(stream.pending_output, output)
  if stream.flush_scheduled then return end

  stream.flush_scheduled = true
  vim.schedule(function()
    stream.flush_scheduled = false
    flush(stream)
  end)
end

function M.finish(stream)
  flush(stream)

  if vim.api.nvim_buf_is_valid(stream.bufnr) then vim.api.nvim_buf_del_extmark(stream.bufnr, stream_namespace, stream.mark_id) end
end

flush = function(stream)
  if #stream.pending_output == 0 then return end

  local output = table.concat(stream.pending_output)
  stream.pending_output = {}

  if stream.insert_failed then return end

  if not M.is_writable(stream.bufnr) then
    fail(stream, 'QQ could not continue writing into the original buffer')
    return
  end

  local position = vim.api.nvim_buf_get_extmark_by_id(stream.bufnr, stream_namespace, stream.mark_id, {})
  if #position == 0 then
    fail(stream, 'QQ could not find its insertion point in the original buffer')
    return
  end

  local row, col = position[1], position[2]
  local lines = vim.split(output, '\n', { plain = true })
  vim.api.nvim_buf_set_text(stream.bufnr, row, col, row, col, lines)
end

fail = function(stream, message)
  stream.insert_failed = true
  stream.on_error(message)
end

return M
