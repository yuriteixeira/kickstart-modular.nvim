local regrafter = require 'custom.helpers.regrafter'

vim.api.nvim_create_user_command('RegrafterExtract', function(command) regrafter.extract_lines(command.line1, command.line2) end, {
  desc = 'Extract selected JSX into a React component',
  range = true,
})

vim.api.nvim_create_user_command('RegrafterInstall', regrafter.install, {
  desc = 'Install the Regrafter Node dependency',
})

vim.keymap.set('x', '<leader>re', regrafter.extract_visual, {
  desc = '[R]efactor: [E]xtract React component',
})
