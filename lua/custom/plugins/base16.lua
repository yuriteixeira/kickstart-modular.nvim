-- base16-nvim
---@module 'lazy'
---@type LazySpec
return {
  'RRethy/base16-nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    local fallback_theme = 'atelier-lakeside'
    local shell_theme = vim.env.BASE16_THEME
    local theme = shell_theme and shell_theme ~= '' and shell_theme or fallback_theme

    require('base16-colorscheme').with_config {
      telescope = true,
      telescope_borders = true,
      indentblankline = true,
      notify = true,
      ts_rainbow = true,
      cmp = true,
      illuminate = true,
      lsp_semantic = true,
      mini_completion = true,
      dapui = true,
      diffview = true,
    }

    local ok = pcall(vim.cmd.colorscheme, 'base16-' .. theme)
    if not ok then
      vim.notify(
        ('base16 theme %q is not available; falling back to %q'):format(theme, fallback_theme),
        vim.log.levels.WARN
      )
      vim.cmd.colorscheme('base16-' .. fallback_theme)
    end
  end,
}
