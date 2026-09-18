local M = {}

local tool_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'tools', 'regrafter')
local bridge_path = vim.fs.joinpath(tool_dir, 'bridge.mjs')
local dependency_path = vim.fs.joinpath(tool_dir, 'node_modules', 'regrafter', 'package.json')
local supported_filetypes = {
  javascriptreact = true,
  typescriptreact = true,
}

local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'Regrafter' }) end

local function resume_thread(thread, ...)
  local values = { ... }
  vim.schedule(function()
    local ok, error_message = coroutine.resume(thread, unpack(values))
    if not ok then notify(error_message, vim.log.levels.ERROR) end
  end)
end

local function await_input(options)
  local thread = coroutine.running()
  vim.ui.input(options, function(value) resume_thread(thread, value) end)
  return coroutine.yield()
end

local function await_select(items, options)
  local thread = coroutine.running()
  vim.ui.select(items, options, function(value) resume_thread(thread, value) end)
  return coroutine.yield()
end

local function await_system(command, options)
  local thread = coroutine.running()
  vim.system(command, options, function(result) resume_thread(thread, result) end)
  return coroutine.yield()
end

local function buffer_content(bufnr) return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n') end

local function is_component_name(value) return value and value:match '^[A-Z][A-Za-z0-9_$]*$' ~= nil end

local function normalized_range(start_position, end_position)
  local start_line, start_column = start_position[2], math.max(start_position[3] - 1, 0)
  local end_line, end_column = end_position[2], math.max(end_position[3], 0)

  if start_line > end_line or (start_line == end_line and start_column > end_column) then
    return {
      start = { line = end_line, column = math.max(end_column - 1, 0) },
      ['end'] = { line = start_line, column = start_column + 1 },
    }
  end

  return {
    start = { line = start_line, column = start_column },
    ['end'] = { line = end_line, column = end_column },
  }
end

local function source_context(range)
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  if not supported_filetypes[filetype] then return nil, 'Open a JSX or TSX file before extraction.' end

  local source_path = vim.api.nvim_buf_get_name(bufnr)
  if source_path == '' then return nil, 'Save the source file before extraction.' end

  return {
    bufnr = bufnr,
    changedtick = vim.api.nvim_buf_get_changedtick(bufnr),
    content = buffer_content(bufnr),
    filetype = filetype,
    source_path = vim.fs.normalize(source_path),
    range = range,
  }
end

local function target_path_for(context, component_name)
  local extension = context.source_path:match '(%.[^.]+)$' or '.tsx'
  local default_name = component_name .. extension
  local value = await_input {
    prompt = 'New component path: ',
    default = default_name,
    completion = 'file',
  }
  if not value or value == '' then return nil end

  local path = value
  if not vim.startswith(path, '/') then path = vim.fs.joinpath(vim.fs.dirname(context.source_path), path) end
  path = vim.fs.normalize(path)

  if path == context.source_path then
    notify('The new component path must differ from the source path.', vim.log.levels.ERROR)
    return nil
  end
  if vim.uv.fs_stat(path) or vim.fn.bufexists(path) == 1 then
    notify('The target file already exists: ' .. path, vim.log.levels.ERROR)
    return nil
  end

  return path
end

local function decode_result(process_result)
  if process_result.code ~= 0 then return nil, process_result.stderr ~= '' and process_result.stderr or 'The Node bridge failed.' end

  local ok, result = pcall(vim.json.decode, process_result.stdout)
  if not ok then return nil, 'Regrafter returned invalid output: ' .. result end
  if not result.ok then
    local error_value = result.error or {}
    return nil, error_value.message or error_value.details or 'Regrafter could not extract this selection.'
  end

  return result.value
end

local function lines_from_content(content)
  local lines = vim.split(content, '\n', { plain = true })
  if lines[#lines] == '' then table.remove(lines) end
  if #lines == 0 then return { '' } end
  return lines
end

local function replace_buffer(bufnr, content)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines_from_content(content))
  vim.bo[bufnr].endofline = true
end

local function find_code(codes, path)
  for _, code in ipairs(codes or {}) do
    if vim.fs.normalize(code.file) == path then return code end
  end
end

local function apply_result(context, target_path, result)
  if not vim.api.nvim_buf_is_valid(context.bufnr) then return nil, 'The source buffer was closed.' end
  if vim.api.nvim_buf_get_changedtick(context.bufnr) ~= context.changedtick then
    return nil, 'The source changed while Regrafter was running. Run extraction again.'
  end

  local source_code = find_code(result.codes, context.source_path)
  if not source_code then return nil, 'Regrafter did not return the changed source file.' end

  local target_code
  if target_path then
    target_code = find_code(result.codes, target_path)
    if not target_code then return nil, 'Regrafter did not return the new component file.' end
    if vim.uv.fs_stat(target_path) then return nil, 'The target file was created by another process.' end
  end

  replace_buffer(context.bufnr, source_code.content)

  if target_code then
    vim.fn.mkdir(vim.fs.dirname(target_path), 'p')
    local target_buffer = vim.fn.bufadd(target_path)
    vim.fn.bufload(target_buffer)
    replace_buffer(target_buffer, target_code.content)
    vim.bo[target_buffer].filetype = context.filetype
    vim.api.nvim_set_current_buf(target_buffer)
  end

  local stats = result.stats or {}
  notify(string.format('Created %s with %d props.', result.component.name, stats.propsGenerated or 0))
  return true
end

local function extraction_workflow(range)
  if not vim.uv.fs_stat(dependency_path) then
    notify('Regrafter is not installed. Run :RegrafterInstall first.', vim.log.levels.ERROR)
    return
  end

  local context, context_error = source_context(range)
  if not context then
    notify(context_error, vim.log.levels.ERROR)
    return
  end

  local component_name = await_input { prompt = 'Component name: ' }
  if not component_name then return end
  if not is_component_name(component_name) then
    notify('Use a React component name that starts with an uppercase letter.', vim.log.levels.ERROR)
    return
  end

  local placement = await_select({ 'Current file', 'New file' }, { prompt = 'Component placement:' })
  if not placement then return end

  local target_path
  if placement == 'New file' then
    target_path = target_path_for(context, component_name)
    if not target_path then return end
  end

  local request = vim.json.encode {
    sourcePath = context.source_path,
    targetPath = target_path,
    content = context.content,
    componentName = component_name,
    range = context.range,
  }
  local process_result = await_system({ 'node', bridge_path }, { stdin = request, text = true })
  local result, result_error = decode_result(process_result)
  if not result then
    notify(result_error, vim.log.levels.ERROR)
    return
  end

  local _, apply_error = apply_result(context, target_path, result)
  if apply_error then notify(apply_error, vim.log.levels.ERROR) end
end

local function start_extraction(range)
  local thread = coroutine.create(extraction_workflow)
  local ok, error_message = coroutine.resume(thread, range)
  if not ok then notify(error_message, vim.log.levels.ERROR) end
end

function M.extract_visual() start_extraction(normalized_range(vim.fn.getpos "'<", vim.fn.getpos "'>")) end

function M.extract_lines(first_line, last_line)
  local end_text = vim.api.nvim_buf_get_lines(0, last_line - 1, last_line, false)[1] or ''
  start_extraction {
    start = { line = first_line, column = 0 },
    ['end'] = { line = last_line, column = #end_text },
  }
end

function M.install()
  if vim.fn.executable 'npm' ~= 1 then
    notify('npm is required to install Regrafter.', vim.log.levels.ERROR)
    return
  end

  notify 'Installing Regrafter...'
  vim.system({ 'npm', 'install', '--ignore-scripts' }, { cwd = tool_dir, text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        notify 'Regrafter is installed.'
      else
        notify(result.stderr ~= '' and result.stderr or 'Regrafter installation failed.', vim.log.levels.ERROR)
      end
    end)
  end)
end

return M
