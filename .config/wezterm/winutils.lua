---@class winutils
local M = {}
local wezterm = require("wezterm") --- @type Wezterm

M.distro_cache = {} ---@type string[]

--- Get registry value
---@param path string
---@param item string
---@return string?
function M.get_reg_value(path, item)
  local cmd = { "reg.exe", "query", path, "/v", item }
  local success, stdout = wezterm.run_child_process(cmd)
  if not success then
    return nil
  end

  local value = stdout:match("REG_%w+%s+(.-)[\r\n]")
  return value and value:match("^%s*(.-)%s*$")
end

--- Get wsl distribution name
--- @param guid string
--- @return string?
function M.get_wsl_distro_name(guid)
  if M.distro_cache[guid] then
    return M.distro_cache[guid]
  end

  local name = M.get_reg_value("HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Lxss\\" .. guid, "DistributionName")
  if name then
    M.distro_cache[guid] = name
    return name
  end
end

--- Get wsl guid from `wslhost.exe` command line arguments
---@param proc LocalProcessInfo
---@return string?
function M.get_wsl_distro_guid(proc)
  for i, arg in ipairs(proc.argv) do
    if arg == "--distro-id" and proc.argv[i + 1] then
      local guid = proc.argv[i + 1]
      return guid
    end
  end
end

return M
