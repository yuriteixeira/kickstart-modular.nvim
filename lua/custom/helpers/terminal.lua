local M = {}

local term = vim.env.TERM

M.is_console = term == 'linux' or term == 'console' or term == 'tmux'
M.is_graphical = not M.is_console

return M
