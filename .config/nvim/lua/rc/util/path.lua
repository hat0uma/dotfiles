local M = {}
local system = require("rc.util.system")

--- Check the path is absolute.
---@param path string
---@return boolean
function M.is_absolute_path(path)
  if system.is_windows() then
    return path:match("^%a:[/\\]") ~= nil or path:match("^[/\\][/\\]") ~= nil
  else
    return path:match("^/") ~= nil
  end
end

--- Make the path absolute.
---@param cwd string?
---@param file string
---@return string
function M.make_absolute(cwd, file)
  if M.is_absolute_path(file) then
    return file
  end

  if cwd == nil then
    return file
  end

  return vim.fs.normalize(vim.fs.joinpath(cwd, file))
end

--- Check the path is accessable.
---@param path string
---@return boolean
function M.accessable(path)
  return vim.loop.fs_access(path, "R", nil) ~= nil
end

return M
