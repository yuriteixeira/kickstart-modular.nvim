local function update_plugins() vim.pack.update() end

vim.api.nvim_create_user_command('PackUpdate', update_plugins, {
  desc = 'Update plugins managed by vim.pack',
})
