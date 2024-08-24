--- This module provides a history navigation feature for oil.nvim.
local M = {}

--- History stack for navigating directories.
--- The history stack is a stack of directories that the user has navigated to.
--- The end is the current directory, and the previous directories are stacked in order.
M.history_stack = {}

--- Forward stack for navigating directories.
--- The forward stack is a stack of directories that the user has navigated to after navigating back.
M.forward_stack = {}

--- Maximum number of directories to keep in the history.
--- When the history stack exceeds this number, the oldest directory is removed.
M.max_history = 100

local notification = nil
local function notify(msg)
  notification = vim.notify(msg, vim.log.levels.INFO, { replace = notification })
end

--- Clear history.
function M.clear()
  M.history_stack = {}
  M.forward_stack = {}
end

--- Push a directory to the history.
---@param dir string
function M.push(dir)
  if M.history_stack[#M.history_stack] == dir then
    return
  end

  -- Clear the forward stack and push to the history stack
  -- example:
  -- history_stack = { "a", "b" }
  -- forward_stack = { "c" }
  -- push("d")
  -- history_stack = { "a", "b", "d" }
  -- current = "d"
  M.forward_stack = {}
  table.insert(M.history_stack, dir)

  -- Remove the oldest directory if the history stack exceeds the maximum number
  if #M.history_stack > M.max_history then
    table.remove(M.history_stack, 1)
  end
end

--- Check if the user can navigate back in the history.
---@return boolean
function M.can_go_back()
  -- if there is only current directory, there is no history to navigate back to
  return #M.history_stack > 1
end

--- Check if the user can navigate forward in the history.
---@return boolean
function M.can_go_forward()
  return #M.forward_stack > 0
end

--- Navigate back in the history.
M.back = {
  desc = "Navigate back in history",
  callback = function()
    if not M.can_go_back() then
      notify("No more history to navigate back to")
      return
    end

    -- Pop the current directory and push it to the forward stack
    -- example:
    -- history_stack = { "a", "b", "c" }
    -- forward_stack = { "d" }
    -- back()
    -- history_stack = { "a", "b" }
    -- forward_stack = { "c", "d" }
    -- current = "c"
    table.insert(M.forward_stack, table.remove(M.history_stack))
    vim.cmd.edit(M.history_stack[#M.history_stack])
  end,
}

--- Navigate forward in the history.
M.forward = {
  desc = "Navigate forward in history",
  callback = function()
    if not M.can_go_forward() then
      notify("No more history to navigate forward to")
      return
    end

    -- Pop the current directory and push it to the history stack
    -- example:
    -- history_stack = { "a", "b" }
    -- forward_stack = { "c", "d" }
    -- forward()
    -- history_stack = { "a", "b", "c" }
    -- forward_stack = { "d" }
    -- current = "c"
    table.insert(M.history_stack, table.remove(M.forward_stack))
    vim.cmd.edit(M.history_stack[#M.history_stack])
  end,
}

--- Setup the history navigation feature.
function M.setup()
  -- push the current directory to the history stack when entering Oil
  vim.api.nvim_create_autocmd("User", {
    pattern = "OilEnter",
    callback = function(opts)
      local dir = assert(require("oil").get_current_dir(opts.data.buf))
      M.push(dir)
    end,
    group = vim.api.nvim_create_augroup("oil-history-settings", {}),
  })
end

return M
