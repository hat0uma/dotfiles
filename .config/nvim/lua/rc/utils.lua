local Path = require "plenary.path"

local M = {}

function M.accessable(path)
  return vim.loop.fs_access(path, "R", nil)
end

function M.rel_or_abs(cwd, file)
  --- @type string
  if cwd == nil then
    return file
  end
  local retpath = Path:new({ cwd, file }):absolute()
  if not M.accessable(retpath) then
    retpath = file
  end
  return retpath
end

return M
