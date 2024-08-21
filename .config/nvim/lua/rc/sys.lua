---@class rc.sys
---@field is_windows boolean Check the system is windows
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

---Open the file or directory with the default application.
---@param args string[] | string | nil
---@return string[]
function M.get_open_command(args)
  local sysname = M.get_sysname()
  if not sysname then
    error("Unsupported system")
  end
  local commands = {
    -- windows = { "rundll32", "url.dll,FileProtocolHandler" },
    windows = { "explorer.exe" }, -- rundll32 is not working for multibyte file names
    mac = { "open" },
    unix = { "xdg-open" },
    wsl = { "/mnt/c/Windows/System32/rundll32.exe", "url.dll,FileProtocolHandler" },
  }

  local cmd = commands[sysname]
  if not cmd then
    error("Unsupported system")
  end

  if type(args) == "string" then
    args = { args }
  elseif type(args) ~= "table" then
    args = {}
  end

  args = vim.tbl_map(function(v)
    return vim.fn.shellescape(v)
  end, args)
  vim.list_extend(cmd, args)
  return cmd
end

return setmetatable(M, {
  __index = function(_, k)
    if k == "is_windows" then
      local v = rawget(M, k)
      if not v then
        v = rawget(M, "get_sysname")() == "windows"
        rawset(M, k, v)
      end
      return v
    else
      return rawget(M, k)
    end
  end,
})
