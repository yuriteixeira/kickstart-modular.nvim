local cmd = vim.api.nvim_create_user_command
local file_path = require 'custom.helpers.file-path'
local indent_info = require 'custom.helpers.indent-info'
local qq = require 'custom.helpers.qq'

local function update_plugins() vim.pack.update() end

cmd('PackUpdate', update_plugins, {
  desc = 'Update plugins managed by vim.pack',
})

cmd('FilePath', file_path.insert_absolute, {
  desc = 'Insert the current buffer absolute file path',
})

cmd('RelativeFilePath', file_path.insert_relative, {
  desc = 'Insert the current buffer relative file path',
})

cmd('IndentInfo', indent_info.show, {
  desc = 'Show indentation settings and their origin',
})

cmd('QQ', qq.run_stream, {
  nargs = '+',
  desc = 'Stream a quick answer to a question into the current buffer',
})
