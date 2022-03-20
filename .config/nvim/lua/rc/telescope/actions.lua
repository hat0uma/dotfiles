local action_set = require "telescope.actions.set"
local state = require "telescope.state"
local action_state = require "telescope.actions.state"

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

function M.enable_preview(bufnr)
  local picker = action_state.get_current_picker(bufnr)
  local status = state.get_status(picker.prompt_bufnr)

  if picker.hidden_previewer and not status.preview_win then
    picker.previewer = picker.hidden_previewer
    picker.hidden_previewer = nil
  end
  picker:full_layout_update()
end

function M.disable_preview(bufnr)
  local picker = action_state.get_current_picker(bufnr)
  local status = state.get_status(picker.prompt_bufnr)

  if picker.previewer and status.preview_win then
    picker.hidden_previewer = picker.previewer
    picker.previewer = nil
  end
  picker:full_layout_update()
end

return M
