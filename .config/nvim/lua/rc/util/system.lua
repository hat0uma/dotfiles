local M = {}

--- Get the system name.
---@return "windows" | "unix" | "mac" | "wsl" | nil
function M.get_sysname()
  local uname = vim.uv.os_uname()
  if uname.sysname:find("Windows") then
    return "windows"
  end

  if uname.sysname == "Darwin" then
    return "mac"
  end

  if uname.sysname == "Linux" then
    if uname.release:lower():find("microsoft") then
      return "wsl"
    else
      return "unix"
    end
  end

  if uname.sysname == "FreeBSD" then
    return "unix"
  end

  return nil
end

--- Check the system is windows.
---@return boolean
function M.is_windows()
  return M.get_sysname() == "windows"
end

return M
