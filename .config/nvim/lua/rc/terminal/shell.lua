local M = {}

---@class rc.terminal.Shell
---@field cmd string
---@field env table<string, string>

--- Shell configurations.
--- @param opts rc.terminal.Shell
--- @return rc.terminal.Shell
local function shell(opts)
  opts.env.PARENT_NVIM_ADDRESS = vim.v.servername
  return opts
end

local function append_bin_to_path(bin)
  local config = vim.fn.stdpath("config")
  assert(type(config) == "string")
  return rc.sys.append_path(vim.fs.joinpath(config, "lua/rc/terminal/", bin))
end

local candidates = {
  pwsh = function()
    return shell({
      cmd = "pwsh -NoLogo",
      env = {
        PATH = append_bin_to_path("bin.pwsh"),
      },
    })
  end,
  zsh = function()
    return shell({
      cmd = "zsh -l",
      env = {
        PATH = append_bin_to_path("bin"),
      },
    })
  end,
}

--- Return shell appropriate for the environment.
---@return rc.terminal.Shell
function M.get()
  return rc.sys.is_windows and candidates.pwsh() or candidates.zsh()
end

return M
