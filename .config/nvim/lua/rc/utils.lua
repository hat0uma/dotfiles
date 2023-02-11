local Path = require "plenary.path"

local M = {}

function M.accessable_path(cwd, file)
  --- @type string
  local retpath = Path:new({ cwd, file }):absolute()
  if not vim.loop.fs_access(retpath, "R", nil) then
    retpath = file
  end
  return retpath
end

return M
