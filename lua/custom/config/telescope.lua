local telescope = require 'telescope'
local builtin = require 'telescope.builtin'

local default_mark_entry_maker

local function mark_entry_maker(entry)
  local mark = entry.line and entry.line:match '^(%a)' or nil
  if mark then return default_mark_entry_maker(entry) end
end

local function find_marks()
  default_mark_entry_maker = require('telescope.make_entry').gen_from_marks {}
  builtin.marks { entry_maker = mark_entry_maker }
end

local function find_open_files()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end

local function find_config_files() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end

local function map_lsp(bufnr, lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc }) end

local function configure_lsp_keymaps(event)
  local bufnr = event.buf
  map_lsp(bufnr, 'gr', builtin.lsp_references, '[G]oto [R]eferences')
  map_lsp(bufnr, 'gi', builtin.lsp_implementations, '[G]oto [I]mplementation')
  map_lsp(bufnr, 'gd', builtin.lsp_definitions, '[G]oto [D]efinition')
  map_lsp(bufnr, 'gs', builtin.lsp_document_symbols, '[G]oto document [S]ymbols')
  map_lsp(bufnr, 'gS', builtin.lsp_dynamic_workspace_symbols, '[G]oto workspace [S]ymbols')
  map_lsp(bufnr, 'gD', builtin.lsp_type_definitions, '[G]oto type [D]efinition')
end

local function delete_map(mode, lhs) pcall(vim.keymap.del, mode, lhs) end

local function remove_upstream_search_keymaps()
  local normal_maps = {
    '<leader>sh',
    '<leader>sk',
    '<leader>sf',
    '<leader>ss',
    '<leader>sw',
    '<leader>sg',
    '<leader>sd',
    '<leader>sr',
    '<leader>s.',
    '<leader>sc',
    '<leader>s/',
    '<leader>sn',
  }

  for _, lhs in ipairs(normal_maps) do
    delete_map('n', lhs)
  end
  delete_map('v', '<leader>sw')
end

telescope.setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--glob',
      '!.git/',
    },
  },
  pickers = {
    find_files = {
      find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/' },
    },
  },
}

remove_upstream_search_keymaps()

vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [K]eymaps' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = '[F]ind [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>fw', builtin.grep_string, { desc = '[F]ind current [W]ord' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' })
vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]ind [R]esume' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = '[F]ind [O]ld recent files' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = '[F]ind [C]ommands' })
vim.keymap.set('n', '<leader>f;', builtin.command_history, { desc = '[F]ind command history' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind existing [B]uffers' })
vim.keymap.set('n', '<leader>fm', find_marks, { desc = '[F]ind [M]arks' })
vim.keymap.set('n', '<leader>f/', find_open_files, { desc = '[F]ind [/] in Open Files' })
vim.keymap.set('n', '<leader>fn', find_config_files, { desc = '[F]ind [N]eovim files' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('custom-telescope-lsp-attach', { clear = true }),
  callback = configure_lsp_keymaps,
})
