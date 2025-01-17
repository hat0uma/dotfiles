local M = {}

---@alias Deferred fun(...:any)...
---@alias Defer fun( f: Deferred, ...:any)

---Call with defer
---@param target_fn fun( defer:Defer )
function M.scope(target_fn)
  local deferred_list = {}

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

  -- Run target functions
  local ok, err = xpcall(target_fn, debug.traceback, defer) --- @type boolean,any

  -- Do deferred functions
  for _ = 1, #deferred_list do
    local f = table.remove(deferred_list)
    pcall(f)
  end

  -- notify errors
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

return M
