local action_set = require "telescope.actions.set"
local state = require "telescope.state"

local M = {}

function M.shift_selection_pagedown(bufnr)
  local status = state.get_status(bufnr)
  local speed = vim.api.nvim_win_get_height(status.results_win) / 2
  action_set.shift_selection(bufnr, math.floor(speed))
end

function M.shift_selection_pageup(bufnr)
  local status = state.get_status(bufnr)
  local speed = vim.api.nvim_win_get_height(status.results_win) / 2
  action_set.shift_selection(bufnr, math.floor(speed) * -1)
end

return M
