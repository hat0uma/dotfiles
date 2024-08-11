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

---Open the file or directory with the default application.
---@param args string[] | string | nil
---@return string[]
function M.get_open_command(args)
  local sysname = M.get_sysname()
  if not sysname then
    error("Unsupported system")
  end
  local commands = {
    windows = { "rundll32", "url.dll,FileProtocolHandler" },
    mac = { "open" },
    unix = { "xdg-open" },
    wsl = { "/mnt/c/Windows/System32/rundll32.exe", "url.dll,FileProtocolHandler" },
  }

  local cmd = commands[sysname]
  if not cmd then
    error("Unsupported system")
  end

  if type(args) == "table" then
    vim.list_extend(cmd, args)
  elseif type(args) == "string" then
    table.insert(cmd, args)
  end
  return cmd
end

return M
