--- The `defer` module provides a mechanism for deferring functions until the end of a scope.
--- For example, this can be used to perform cleanup operations, restore configurations,
--- or run any tasks that should only happen once the main logic has finished.
local M = {}

--- Represents a callback function that can receive any number of arguments.
---@alias Deferred fun(...: any)

--- A function that registers a `Deferred` callback (and optional arguments) to be executed later.
---
--- - When no extra arguments are passed, the callback is stored as is.
--- - When extra arguments are provided, they are unpacked during the deferred call.
---@alias Defer fun(cb: Deferred, ...: any)

--- The `scope` function executes a given `target_fn`, providing it with a `defer` argument.
--- Any functions registered via `defer` will be executed at the end, in a LIFO (Last In, First Out) order.
---
--- ### Example
--- ```lua
--- local d = require("<this_module>")
---
--- d.scope(function(defer)
---   print("Main process start")
---   defer(print, "Deferred call 1")
---   defer(print, "Deferred call 2: Hello!")
---   print("Main process end")
--- end)
--- ```
---
--- *Output* (order of prints):
--- ```
--- Main process start
--- Main process end
--- Deferred call 2: Hello!
--- Deferred call 1
--- ```
---
---@param target_fn fun(defer_fn: Defer) A function that receives `defer_fn` to register deferred tasks.
function M.scope(target_fn)
  local deferred_list = {}

  ---The internal function used as the `defer` argument within the `scope` function.
  ---It stores the deferred functions in `deferred_list` to be executed later
  ---@type Defer
  local function defer(deferred, ...)
    local args = { ... }
    if #args == 0 then
      table.insert(deferred_list, deferred)
      return
    end

    table.insert(deferred_list, function()
      deferred(unpack(args))
    end)
  end

  -- Execute target function
  local ok, err = xpcall(target_fn, debug.traceback, defer) --- @type boolean,any

  -- Execute deferred functions in reverse order (LIFO).
  for _ = 1, #deferred_list do
    local f = table.remove(deferred_list)
    pcall(f)
  end

  -- Notify if an error occurred during the `target_fn` execution
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

return M
